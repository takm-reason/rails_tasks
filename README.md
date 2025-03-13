# Rails Tasks Application

## 概要
タスク管理のためのRailsアプリケーションです。AWSのECS環境で動作することを想定して設計されています。

## 技術スタック
- Ruby 3.3.5
- Ruby on Rails 7.x
- PostgreSQL 15 (本番環境)
- SQLite3 (開発・テスト環境)
- AWS (ECS, RDS, S3, ALB, ECR)

## ECRへのイメージアップロード手順

1. AWSアカウントにログイン
```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```

2. Dockerイメージのビルド
```bash
docker build -t rails-tasks .
```

3. ECRリポジトリのイメージ名を設定
```bash
docker tag rails-tasks:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:latest
```

4. ECRへのプッシュ
```bash
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:latest
```

注意: 以下の環境変数を設定してください：
- AWS_ACCOUNT_ID: AWSアカウントID
- APPLICATION_NAME: アプリケーション名（ECRリポジトリ名）

## AWS環境設定

1. `aws_resources.template.yml`を`aws_resources.{environment}.yml`にコピーし、環境に応じた値を設定します。
2. 各環境のリソース設定は`.gitignore`により管理対象外となっています。

### データベース接続設定

1. `config/initializers/aws.rb.sample`を`config/initializers/aws.rb`にコピーします：
```bash
cp config/initializers/aws.rb.sample config/initializers/aws.rb
```

2. デプロイ時のデータベース接続について：
   - アプリケーションは`aws_resources.{environment}.yml`から自動的にデータベース接続情報を読み込みます
   - 接続情報は以下の形式でDATABASE_URL環境変数として設定されます：
     `postgresql://username:password@host:5432/dbname`
   - ECSタスク実行時に必要な環境変数は自動的に設定されます

3. ローカルでの動作確認：
```bash
# 開発環境用の設定ファイルを作成
cp aws_resources.template.yml aws_resources.development.yml
# 設定ファイルを編集して適切な値を設定
vim aws_resources.development.yml
```

## ECSデプロイ手順

1. 環境変数の設定
```bash
# aws_resources.development.ymlから値を取得して設定
export AWS_ACCOUNT_ID=661518172232  # または環境に応じたアカウントID
export APPLICATION_NAME=test202503121720  # aws_resources.development.ymlのapplication.nameの値
export AWS_DEFAULT_REGION=ap-northeast-1  # またはaws.regionの値
```

2. ECRへのログインとイメージプッシュ
```bash
# ECRにログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

# Dockerイメージのビルド
docker build -t ${APPLICATION_NAME} .

# イメージのタグ付け
docker tag ${APPLICATION_NAME}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:latest

# ECRへのプッシュ
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${APPLICATION_NAME}:latest
```

3. ECSサービスの更新
```bash
# aws_resources.development.ymlからECSサービス情報を使用してデプロイ
aws ecs update-service \
  --cluster test202503121720-development-small-SmallScaleClusterC3C72710-cBURAMu0inDC \
  --service test202503121720-development-small-SmallScaleServiceC1FBF063-yVJKLaUVYSdY \
  --force-new-deployment
```

4. デプロイの確認
```bash
# サービスの状態を確認
aws ecs describe-services \
  --cluster test202503121720-development-small-SmallScaleClusterC3C72710-cBURAMu0inDC \
  --services test202503121720-development-small-SmallScaleServiceC1FBF063-yVJKLaUVYSdY

# CloudWatchログの確認
aws logs tail test202503121720-development-small-SmallScaleServiceTaskDefwebLogGroupA28684CD-CS5arV1GERzW
```

注意事項：
- デプロイ前に必ず`aws_resources.development.yml`の設定値が正しいことを確認してください
- ECSタスク定義はインフラ側で管理されているため、手動での更新は不要です
- アプリケーションの環境変数は`aws_resources.development.yml`の値から自動的に設定されます

## API仕様
API仕様については[API仕様書](docs/api.md)を参照してください。

[以下、既存のREADMEの内容を続ける...]
