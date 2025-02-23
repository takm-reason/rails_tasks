#!/bin/bash

# タスク管理APIのテストスクリプト
BASE_URL="http://localhost:3000"
CONTENT_TYPE="Content-Type: application/json"

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "タスク管理APIテスト開始"
echo "======================="
echo

echo "1. タスクの作成"
echo "---------------"
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/tasks.json" \
  -H "$CONTENT_TYPE" \
  -d '{
    "task": {
      "title": "テストタスク",
      "description": "APIテスト用のタスク",
      "due_date": "2025-03-01T17:00:00+09:00",
      "priority": 1
    }
  }')

if [[ $CREATE_RESPONSE == *"id"* ]]; then
  echo -e "${GREEN}✓ タスク作成成功${NC}"
  TASK_ID=$(echo $CREATE_RESPONSE | python3 -m json.tool | grep '"id":' | cut -d'"' -f4)
  echo "作成されたタスクID: $TASK_ID"
  echo $CREATE_RESPONSE | python3 -m json.tool
else
  echo -e "${RED}✗ タスク作成失敗${NC}"
  echo $CREATE_RESPONSE | python3 -m json.tool
  exit 1
fi

echo

echo "2. タスク一覧の取得"
echo "------------------"
LIST_RESPONSE=$(curl -s -X GET "$BASE_URL/tasks.json")
if [[ $LIST_RESPONSE == *"["* ]]; then
  echo -e "${GREEN}✓ タスク一覧取得成功${NC}"
  echo $LIST_RESPONSE | python3 -m json.tool
else
  echo -e "${RED}✗ タスク一覧取得失敗${NC}"
  echo $LIST_RESPONSE
fi
echo

echo "3. タスクの更新"
echo "---------------"
UPDATE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/tasks/$TASK_ID.json" \
  -H "$CONTENT_TYPE" \
  -d '{
    "task": {
      "title": "更新されたタスク",
      "description": "更新されたタスクの説明",
      "priority": 2
    }
  }')

if [[ $UPDATE_RESPONSE == *"id"* ]]; then
  echo -e "${GREEN}✓ タスク更新成功${NC}"
  echo $UPDATE_RESPONSE | python3 -m json.tool
else
  echo -e "${RED}✗ タスク更新失敗${NC}"
  echo $UPDATE_RESPONSE
fi
echo

echo "4. タスクの完了"
echo "--------------"
COMPLETE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/tasks/$TASK_ID/complete.json")
if [[ $COMPLETE_RESPONSE == *"is_completed\":true"* ]]; then
  echo -e "${GREEN}✓ タスク完了成功${NC}"
  echo $COMPLETE_RESPONSE | python3 -m json.tool
else
  echo -e "${RED}✗ タスク完了失敗${NC}"
  echo $COMPLETE_RESPONSE
fi
echo

echo "5. タスクの未完了"
echo "----------------"
UNCOMPLETE_RESPONSE=$(curl -s -X PATCH "$BASE_URL/tasks/$TASK_ID/uncomplete.json")
if [[ $UNCOMPLETE_RESPONSE == *"is_completed\":false"* ]]; then
  echo -e "${GREEN}✓ タスク未完了設定成功${NC}"
  echo $UNCOMPLETE_RESPONSE | python3 -m json.tool
else
  echo -e "${RED}✗ タスク未完了設定失敗${NC}"
  echo $UNCOMPLETE_RESPONSE
fi
echo

echo "6. タスクの削除"
echo "--------------"
DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/tasks/$TASK_ID.json")
if [ "$DELETE_STATUS" -eq 204 ]; then
  echo -e "${GREEN}✓ タスク削除成功${NC}"
else
  echo -e "${RED}✗ タスク削除失敗 (ステータスコード: $DELETE_STATUS)${NC}"
fi
echo

echo "テスト完了"
echo "=========="