require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get api_tasks_url, as: :json
    assert_response :success
  end

  test "should get index sorted by priority" do
    get api_tasks_url(sort: 'priority'), as: :json
    assert_response :success
    tasks = JSON.parse(response.body)
    assert tasks.present?
    # 優先度が高い順になっているか確認
    priorities = tasks.map { |t| t['priority'] }
    expected_order = %w[high high high medium low]
    assert_equal expected_order, priorities.first(5)
  end

  test "should get index sorted by due_date" do
    get api_tasks_url(sort: 'due_date'), as: :json
    assert_response :success
    tasks = JSON.parse(response.body)
    assert tasks.present?
    # 期限日順になっているか確認（nilは後ろに配置）
    dates = tasks.map { |t| t['due_date'] }
    non_null_dates = dates.compact
    assert_equal non_null_dates.sort, non_null_dates, "期限日が設定されているタスクが昇順でソートされていません"
    assert dates.count { |d| d.nil? } <= dates.size - non_null_dates.size, "期限日が設定されていないタスクが後ろに配置されていません"
  end

  test "should get index sorted by created_at by default" do
    get api_tasks_url, as: :json
    assert_response :success
    tasks = JSON.parse(response.body)
    assert tasks.present?
    # 作成日時の降順になっているか確認
    created_ats = tasks.map { |t| t['created_at'] }
    assert_equal created_ats.sort.reverse, created_ats
  end

  test "should get completed tasks" do
    get completed_api_tasks_url, as: :json
    assert_response :success
    tasks = JSON.parse(response.body)
    assert tasks.present?
    # すべてのタスクが完了済みであることを確認
    assert tasks.all? { |t| t['completed_at'].present? }
    assert_includes tasks.map { |t| t['id'] }, tasks(:completed).id
  end

  test "should create task" do
    assert_difference("Task.count") do
      post api_tasks_url,
           params: { 
             task: { 
               title: "New Task", 
               description: "Test Description",
               priority: "high"
             } 
           },
           as: :json
    end

    assert_response :created
    task = JSON.parse(response.body)
    assert_equal "high", task['priority']
  end

  test "should create task with default priority" do
    assert_difference("Task.count") do
      post api_tasks_url,
           params: { 
             task: { 
               title: "New Task", 
               description: "Test Description"
             } 
           },
           as: :json
    end

    assert_response :created
    task = JSON.parse(response.body)
    assert_equal "medium", task['priority']
  end

  test "should show task" do
    get api_task_url(@task), as: :json
    assert_response :success
    task = JSON.parse(response.body)
    assert_equal "high", task['priority']
    refute task.key?('is_completed'), "is_completedフィールドは非表示であるべき"
  end

  test "should update task" do
    patch api_task_url(@task),
          params: { task: { priority: "low" } },
          as: :json
    assert_response :success
    task = JSON.parse(response.body)
    assert_equal "low", task['priority']
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
    task = JSON.parse(response.body)
    assert task['completed_at'].present?
  end

  test "should uncomplete task" do
    @task.update!(completed_at: Time.current)
    patch uncomplete_api_task_url(@task), as: :json
    assert_response :success
    task = JSON.parse(response.body)
    assert_nil task['completed_at']
  end

  test "should return not found error for non-existent task" do
    get api_task_url(id: 99999), as: :json
    assert_response :not_found
    error = JSON.parse(response.body)
    assert_equal "リソースが見つかりませんでした", error["message"]
  end

  test "should return bad request error for missing parameters" do
    post api_tasks_url, params: {}, as: :json
    assert_response :bad_request
    error = JSON.parse(response.body)
    assert_equal "パラメータが不正です", error["message"]
    assert error["detail"].present?
  end

  test "should return unprocessable entity for invalid task data" do
    post api_tasks_url, params: { task: { title: "" } }, as: :json
    assert_response :unprocessable_entity
    error = JSON.parse(response.body)
    assert_equal "タスクの作成に失敗しました", error["message"]
    assert error["errors"].present?
    assert error["errors"]["title"].present?
  end

  test "should return unprocessable entity for invalid priority" do
    patch api_task_url(@task), params: { task: { priority: "invalid" } }, as: :json
    assert_response :unprocessable_entity
    error = JSON.parse(response.body)
    assert_equal "プライオリティの値が不正です", error["message"]
    assert_equal ["は'low', 'medium', 'high'のいずれかを指定してください"], error["errors"]["priority"]
  end

  test "should handle priority in create request" do
    %w[low medium high].each do |priority|
      post api_tasks_url,
           params: { 
             task: { 
               title: "Priority Test Task",
               priority: priority 
             } 
           },
           as: :json
      assert_response :created
      task = JSON.parse(response.body)
      assert_equal priority, task['priority']
    end
  end
end