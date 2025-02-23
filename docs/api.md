# タスク管理API仕様書

## 基本情報

* ベースURL: `/api`
* レスポンス形式: JSON
* 文字コード: UTF-8

## エンドポイント一覧

### タスク一覧の取得

```
GET /api/tasks
```

#### クエリパラメータ
- `sort`: ソート方法（オプション）
  - `priority`: 優先度順
  - `due_date`: 期限日順
  - デフォルト: 作成日時の降順

#### レスポンス例
```json
[
  {
    "id": 1,
    "title": "タスク1",
    "description": "説明文",
    "priority": "high",
    "due_date": "2025-03-01",
    "completed_at": null,
    "created_at": "2025-02-23T12:00:00.000Z",
    "updated_at": "2025-02-23T12:00:00.000Z"
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
  "id": 1,
  "title": "タスク1",
  "description": "説明文",
  "priority": "high",
  "due_date": "2025-03-01",
  "completed_at": null,
  "created_at": "2025-02-23T12:00:00.000Z",
  "updated_at": "2025-02-23T12:00:00.000Z"
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
    "due_date": "2025-03-01",
    "priority": "high"
  }
}
```

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
    "description": "更新後の説明文"
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

### タスクの未完了への変更

```
PATCH /api/tasks/:id/uncomplete
```

#### レスポンス
- 成功時: 200 OK

## エラーレスポンス

### バリデーションエラー (422 Unprocessable Entity)
```json
{
  "errors": {
    "title": ["を入力してください"],
    "priority": ["は不正な値です"]
  }
}
```

### リソースが見つからない (404 Not Found)
```json
{
  "error": "Couldn't find Task with 'id'=1"
}