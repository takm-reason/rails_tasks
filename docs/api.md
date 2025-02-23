# タスク管理API仕様書

## 基本情報

* ベースURL: `/api`
* レスポンス形式: JSON
* 文字コード: UTF-8
* 日時形式: ISO 8601形式（例: `2025-02-23T12:00:00.000Z`）

## タスクの属性

### プライオリティ（priority）
- `"high"`: 優先度高
- `"medium"`: 優先度中（デフォルト）
- `"low"`: 優先度低

### タスクの状態
- 未完了: `completed_at` が `null`
- 完了済み: `completed_at` に完了日時が設定される

## エンドポイント一覧

### タスク一覧の取得

```
GET /api/tasks
```

#### クエリパラメータ
- `sort`: ソート方法（オプション）
  - `priority`: 優先度順（high → medium → low）
  - `due_date`: 期限日順（未設定のタスクは後ろに配置）
  - デフォルト: 作成日時の降順

#### レスポンス例
```json
[
  {
    "id": "11111111-1111-1111-1111-111111111111",
    "title": "タスク1",
    "description": "説明文",
    "priority": "high",
    "due_date": "2025-03-01T00:00:00.000Z",
    "completed_at": null,
    "created_at": "2025-02-23T12:00:00.000Z"
  }
]
```

### 完了済みタスク一覧の取得

```
GET /api/tasks/completed
```

#### レスポンス例
```json
[
  {
    "id": "44444444-4444-4444-4444-444444444444",
    "title": "完了したタスク",
    "description": "説明文",
    "priority": "high",
    "due_date": "2025-03-01T00:00:00.000Z",
    "completed_at": "2025-02-23T12:00:00.000Z",
    "created_at": "2025-02-23T12:00:00.000Z"
  }
]
```

### タスクの詳細取得

```
GET /api/tasks/:id
```

#### レスポンス例
```json
{
  "id": "11111111-1111-1111-1111-111111111111",
  "title": "タスク1",
  "description": "説明文",
  "priority": "high",
  "due_date": "2025-03-01T00:00:00.000Z",
  "completed_at": null,
  "created_at": "2025-02-23T12:00:00.000Z"
}
```

### タスクの作成

```
POST /api/tasks
```

#### リクエストボディ
```json
{
  "task": {
    "title": "新しいタスク",
    "description": "説明文",
    "due_date": "2025-03-01T00:00:00.000Z",
    "priority": "high"
  }
}
```

#### 必須フィールド
- `title`: タスクのタイトル

#### オプションフィールド
- `description`: タスクの説明
- `due_date`: 期限日（ISO 8601形式）
- `priority`: 優先度（デフォルト: "medium"）

#### レスポンス
- 成功時: 201 Created
- エラー時: 422 Unprocessable Entity

### タスクの更新

```
PATCH /api/tasks/:id
```

#### リクエストボディ
```json
{
  "task": {
    "title": "更新後のタイトル",
    "description": "更新後の説明文",
    "priority": "low"
  }
}
```

#### レスポンス
- 成功時: 200 OK
- エラー時: 422 Unprocessable Entity

### タスクの削除

```
DELETE /api/tasks/:id
```

#### レスポンス
- 成功時: 204 No Content

### タスクの完了

```
PATCH /api/tasks/:id/complete
```

#### レスポンス
- 成功時: 200 OK
- エラー時: 404 Not Found

### タスクの未完了への変更

```
PATCH /api/tasks/:id/uncomplete
```

#### レスポンス
- 成功時: 200 OK
- エラー時: 404 Not Found

## エラーレスポンス

### パラメータ不正 (400 Bad Request)
```json
{
  "message": "パラメータが不正です",
  "detail": "param is missing or the value is empty: task"
}
```

### バリデーションエラー (422 Unprocessable Entity)
```json
{
  "message": "タスクの作成に失敗しました",
  "errors": {
    "title": ["を入力してください"],
    "priority": ["は'low', 'medium', 'high'のいずれかを指定してください"]
  }
}
```

### プライオリティ不正 (422 Unprocessable Entity)
```json
{
  "message": "プライオリティの値が不正です",
  "errors": {
    "priority": ["は'low', 'medium', 'high'のいずれかを指定してください"]
  }
}
```

### リソースが見つからない (404 Not Found)
```json
{
  "message": "リソースが見つかりませんでした"
}