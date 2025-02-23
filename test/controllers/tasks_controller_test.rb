require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get index with turbo_stream format" do
    get tasks_url, as: :turbo_stream
    assert_response :success
  end

  test "should get show" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { title: "New Task", description: "Test Description" } }
    end

    assert_redirected_to tasks_url
  end

  test "should create task with turbo_stream format" do
    assert_difference("Task.count") do
      post tasks_url,
           params: { task: { title: "New Task", description: "Test Description" } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { title: "Updated Task" } }
    assert_redirected_to tasks_url
  end

  test "should update task with turbo_stream format" do
    patch task_url(@task),
          params: { task: { title: "Updated Task" } },
          as: :turbo_stream
    assert_response :success
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end

  test "should destroy task with turbo_stream format" do
    assert_difference("Task.count", -1) do
      delete task_url(@task), as: :turbo_stream
    end

    assert_response :success
  end

  test "should complete task" do
    patch complete_task_url(@task)
    assert_redirected_to tasks_url
    assert @task.reload.completed?
  end

  test "should complete task with turbo_stream format" do
    patch complete_task_url(@task), as: :turbo_stream
    assert_response :success
    assert @task.reload.completed?
  end

  test "should uncomplete task" do
    @task.update!(completed_at: Time.current)
    patch uncomplete_task_url(@task)
    assert_redirected_to tasks_url
    refute @task.reload.completed?
  end

  test "should uncomplete task with turbo_stream format" do
    @task.update!(completed_at: Time.current)
    patch uncomplete_task_url(@task), as: :turbo_stream
    assert_response :success
    refute @task.reload.completed?
  end
end
