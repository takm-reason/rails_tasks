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

### ECSへのデプロイ
アプリケーションはAWS ECSにデプロイされ、以下の設定が適用されます：
- ALBによるHTTPS終端
- IAMロールによるAWSリソースへのアクセス
- ECSタスク定義に基づくリソース制限
- CloudWatchによるログ管理

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
