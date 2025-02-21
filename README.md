# Rails Tasks Application

## 概要
タスク管理のためのRailsアプリケーションです。AWSのECS環境で動作することを想定して設計されています。

## 技術スタック
- Ruby 3.3.5
- Ruby on Rails 7.x
- PostgreSQL 15 (本番環境)
- SQLite3 (開発・テスト環境)
- AWS (ECS, RDS, S3, ALB)

## 開発環境のセットアップ

### 必要な環境
- Ruby 3.3.5
- SQLite3
- Node.js
- Yarn

### インストール手順
```bash
# リポジトリのクローン
git clone [repository-url]
cd rails_tasks

# 依存関係のインストール
bundle install
yarn install

# データベースのセットアップ
bin/rails db:create
bin/rails db:migrate

# 開発サーバーの起動
bin/rails server
```

## AWS環境設定

### AWS関連の設定

1. AWS設定ファイルの準備:
```bash
# サンプルファイルをコピーして設定ファイルを作成
cp config/initializers/aws.rb.sample config/initializers/aws.rb

# 作成したファイルを編集し、実際の値を設定
vim config/initializers/aws.rb
```

2. 設定項目:
- `region`: AWSリージョン（例：ap-northeast-1）
- `s3.bucket`: S3バケット名（環境変数 S3_BUCKET でも設定可能）
- `rds.database_url`: データベース接続情報（環境変数 DATABASE_URL でも設定可能）
- `alb.host`: ALBのDNS名
- `ecs`: ECSタスク定義の設定値

注意: `aws.rb`は`.gitignore`に含まれており、プロジェクト固有の設定値はリポジトリにコミットされません。

### 必要な環境変数
```bash
# データベース接続
DATABASE_URL=postgresql://user:pass@your-db-endpoint:5432/app

# S3バケット
S3_BUCKET=your-bucket-name

# Rails設定
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
RAILS_MASTER_KEY=your-master-key

# ログレベル（オプション）
RAILS_LOG_LEVEL=info
```

## ECSでの実行

### コンテナリソース
- メモリ: 1024MB
- CPU: 512 units
- コンテナポート: 80
- オートスケーリング: 1-2インスタンス（CPU使用率75%でスケール）

### ストレージ設定
- データベース: Amazon RDS (PostgreSQL 15)
- ファイルストレージ: Amazon S3
- コンテナログ: CloudWatch Logs

## デプロイ方法

### コンテナイメージのビルド
```bash
docker build -t rails_tasks .
```

### ECSへのデプロイ手順

#### 1. 前提条件
- AWS CLIのインストールと設定
- Docker CLIのインストール
- 必要なIAMロールとポリシーの設定
  - ECSタスク実行ロール
  - ECSタスクロール（S3アクセス用）

#### 2. AWS認証情報の設定
```bash
# AWS CLIの設定
aws configure
AWS Access Key ID: [your-access-key]
AWS Secret Access Key: [your-secret-key]
Default region name: ap-northeast-1
Default output format: json
```

#### 3. ECRリポジトリの作成とプッシュ
```bash
# ECRリポジトリ作成
aws ecr create-repository --repository-name rails-tasks

# リポジトリURLの取得
export ECR_REPO=$(aws ecr describe-repositories --repository-names rails-tasks --query 'repositories[0].repositoryUri' --output text)

# ECRログイン
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REPO

# イメージビルドとプッシュ
docker build -t rails-tasks .
docker tag rails-tasks:latest $ECR_REPO:latest
docker push $ECR_REPO:latest
```

#### 4. ECSタスク定義の作成
```bash
# タスク定義ファイルの作成
cat > task-definition.json << EOF
{
  "family": "rails-tasks",
  "requiresCompatibilities": ["FARGATE"],
  "networkMode": "awsvpc",
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::[account-id]:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::[account-id]:role/ecsTaskRole",
  "containerDefinitions": [{
    "name": "rails-tasks",
    "image": "${ECR_REPO}:latest",
    "portMappings": [{
      "containerPort": 80,
      "protocol": "tcp"
    }],
    "environment": [
      {"name": "RAILS_ENV", "value": "production"},
      {"name": "RAILS_SERVE_STATIC_FILES", "value": "true"},
      {"name": "RAILS_LOG_TO_STDOUT", "value": "true"}
    ],
    "secrets": [
      {
        "name": "DATABASE_URL",
        "valueFrom": "arn:aws:secretsmanager:[region]:[account-id]:secret:DATABASE_URL"
      },
      {
        "name": "RAILS_MASTER_KEY",
        "valueFrom": "arn:aws:secretsmanager:[region]:[account-id]:secret:RAILS_MASTER_KEY"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/rails-tasks",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
EOF

# タスク定義の登録
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

#### 5. ECSサービスの作成
```bash
# サービス作成（初回）
aws ecs create-service \
  --cluster your-cluster-name \
  --service-name rails-tasks \
  --task-definition rails-tasks \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx,subnet-yyy],securityGroups=[sg-zzz],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:[region]:[account-id]:targetgroup/rails-tasks/xxx,containerName=rails-tasks,containerPort=80"

# サービス更新（デプロイ時）
aws ecs update-service \
  --cluster your-cluster-name \
  --service rails-tasks \
  --task-definition rails-tasks \
  --force-new-deployment
```

#### 6. デプロイ後の確認
```bash
# サービスステータスの確認
aws ecs describe-services \
  --cluster your-cluster-name \
  --services rails-tasks

# タスクのステータス確認
aws ecs list-tasks \
  --cluster your-cluster-name \
  --service-name rails-tasks

# CloudWatchログの確認
aws logs get-log-events \
  --log-group-name /ecs/rails-tasks \
  --log-stream-name [task-id]
```

#### 7. スケーリングの設定
```bash
# Auto Scalingターゲットの作成
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/your-cluster-name/rails-tasks \
  --min-capacity 1 \
  --max-capacity 2

# スケーリングポリシーの設定
aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/your-cluster-name/rails-tasks \
  --policy-name cpu75-target-tracking-scaling \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 75.0,
    "PredefinedMetricSpecification": {
        "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    }
  }'
```

#### トラブルシューティング
1. デプロイ失敗時の確認ポイント
   - ECSタスクのステータス
   - CloudWatchログ
   - ヘルスチェックの状態
   - セキュリティグループの設定

2. よくある問題の解決方法
   - データベース接続エラー → DATABASE_URLの確認
   - S3アクセスエラー → IAMロールの権限確認
   - メモリ不足 → ECSタスク定義のメモリ設定を確認

## 開発ガイドライン

### テストの実行
```bash
bin/rails test
```

### Linterの実行
```bash
bin/rubocop
```

### 静的コード解析
```bash
bin/brakeman
```

## トラブルシューティング

### データベース接続の確認
```bash
bin/rails db:version
```

### ログの確認
本番環境のログはCloudWatch Logsで確認できます。
開発環境のログは`log/development.log`に出力されます。

## セキュリティ

- SSL終端はALBで実施
- 機密情報はAWS Secrets Managerで管理
- IAMロールによる最小権限の原則に基づいたアクセス制御
- セキュリティグループによるネットワークアクセス制御

## ライセンス
MIT License
