# Rails Tasks API仕様書

## タスク管理API

### 1. タスク一覧の取得

```bash
curl -X GET http://localhost:3000/tasks.json
```

レスポンス例:
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "タスクのタイトル",
    "description": "タスクの説明",
    "createdAt": "2025-02-22T12:52:58+09:00",
    "dueDate": "2025-03-01T17:00:00+09:00",
    "isCompleted": false,
    "completedAt": null,
    "priority": 1
  }
]
```

### 2. タスクの作成

```bash
curl -X POST http://localhost:3000/tasks.json \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "新しいタスク",
      "description": "タスクの説明",
      "due_date": "2025-03-01T17:00:00+09:00",
      "priority": 1
    }
  }'
```

レスポンス例:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "新しいタスク",
  "description": "タスクの説明",
  "createdAt": "2025-02-22T12:52:58+09:00",
  "dueDate": "2025-03-01T17:00:00+09:00",
  "isCompleted": false,
  "completedAt": null,
  "priority": 1
}
```

### 3. タスクの更新

```bash
curl -X PATCH http://localhost:3000/tasks/550e8400-e29b-41d4-a716-446655440000.json \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "更新したタスク",
      "description": "更新した説明",
      "due_date": "2025-03-01T17:00:00+09:00",
      "priority": 2
    }
  }'
```

レスポンス例:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "更新したタスク",
  "description": "更新した説明",
  "createdAt": "2025-02-22T12:52:58+09:00",
  "dueDate": "2025-03-01T17:00:00+09:00",
  "isCompleted": false,
  "completedAt": null,
  "priority": 2
}
```

### 4. タスクの削除

```bash
curl -X DELETE http://localhost:3000/tasks/550e8400-e29b-41d4-a716-446655440000.json
```

レスポンス: 204 No Content

### 5. タスクの完了状態の変更

完了:
```bash
curl -X PATCH http://localhost:3000/tasks/550e8400-e29b-41d4-a716-446655440000/complete.json
```

未完了:
```bash
curl -X PATCH http://localhost:3000/tasks/550e8400-e29b-41d4-a716-446655440000/uncomplete.json
```

レスポンス例:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "タスクのタイトル",
  "description": "タスクの説明",
  "createdAt": "2025-02-22T12:52:58+09:00",
  "dueDate": "2025-03-01T17:00:00+09:00",
  "isCompleted": true,
  "completedAt": "2025-02-22T13:00:00+09:00",
  "priority": 1
}
```

## レスポンスコード

- 200 OK: リクエスト成功
- 201 Created: リソース作成成功
- 204 No Content: リソース削除成功
- 400 Bad Request: パラメータが不正
- 404 Not Found: リソースが見つからない
- 422 Unprocessable Entity: バリデーションエラー
- 500 Internal Server Error: サーバーエラー