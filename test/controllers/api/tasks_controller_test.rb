require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get api_tasks_url, as: :json
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post api_tasks_url,
           params: { task: { title: "New Task", description: "Test Description" } },
           as: :json
    end

    assert_response :created
  end

  test "should show task" do
    get api_task_url(@task), as: :json
    assert_response :success
  end

  test "should update task" do
    patch api_task_url(@task),
          params: { task: { title: "Updated Task" } },
          as: :json
    assert_response :success
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete api_task_url(@task), as: :json
    end

    assert_response :no_content
  end

  test "should complete task" do
    patch complete_api_task_url(@task), as: :json
    assert_response :success
    assert @task.reload.completed?
  end

  test "should uncomplete task" do
    @task.update!(completed_at: Time.current)
    patch uncomplete_api_task_url(@task), as: :json
    assert_response :success
    refute @task.reload.completed?
  end

  test "should return not found error for non-existent task" do
    get api_task_url(id: 99999), as: :json
    assert_response :not_found
    assert_equal({ "error" => "リソースが見つかりませんでした" }, JSON.parse(response.body))
  end

  test "should return bad request error for missing parameters" do
    post api_tasks_url, params: {}, as: :json
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "パラメータが不正です", json_response["error"]
    assert_includes json_response["detail"], "param is missing or the value is empty: task"
  end

  test "should return unprocessable entity for invalid task data" do
    post api_tasks_url, params: { task: { title: "" } }, as: :json
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
    assert json_response["errors"]["title"].present?
  end

  test "should return unprocessable entity for invalid priority" do
    patch api_task_url(@task), params: { task: { priority: 999 } }, as: :json
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
    assert json_response["errors"]["priority"].present?
  end
end