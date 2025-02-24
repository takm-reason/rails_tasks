require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @task = Task.new(
      title: "Test Task",
      description: "Test Description",
      priority: 1
    )
  end

  test "should be valid with valid attributes" do
    assert @task.valid?
  end

  test "should require title" do
    @task.title = nil
    refute @task.valid?
    assert_includes @task.errors[:title], "can't be blank"
  end

  test "should validate priority range" do
    @task.priority = 3
    refute @task.valid?
    assert_includes @task.errors[:priority], "is not included in the list"

    @task.priority = -1
    refute @task.valid?
    assert_includes @task.errors[:priority], "is not included in the list"

    valid_priorities = [0, 1, 2]
    valid_priorities.each do |priority|
      @task.priority = priority
      assert @task.valid?
    end
  end

  test "should set uuid before create" do
    @task.save!
    assert_not_nil @task.id
    assert_match /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, @task.id
  end

  test "should complete task" do
    @task.save!
    assert_changes -> { @task.completed? }, from: false, to: true do
      @task.complete!
    end
    assert_not_nil @task.completed_at
  end

  test "should uncomplete task" do
    @task.save!
    @task.complete!
    assert_changes -> { @task.completed? }, from: true, to: false do
      @task.uncomplete!
    end
    assert_nil @task.completed_at
  end

  test "should return correct priority text" do
    priority_texts = {
      0 => "low",
      1 => "medium",
      2 => "high"
    }

    priority_texts.each do |priority, text|
      @task.priority = priority
      assert_equal text, @task.priority_text
    end
  end

  test "should return priority values" do
    expected = {
      low: 0,
      medium: 1,
      high: 2
    }
    assert_equal expected, Task.priority_values
  end

  test "should order by priority" do
    Task.delete_all
    low = Task.create!(title: "Low", priority: 0)
    high = Task.create!(title: "High", priority: 2)
    medium = Task.create!(title: "Medium", priority: 1)

    tasks = Task.ordered_by_priority
    assert_equal [high, medium, low], tasks.to_a
  end

  test "should order by due date" do
    Task.delete_all
    future = Task.create!(title: "Future", due_date: 3.days.from_now)
    past = Task.create!(title: "Past", due_date: 1.day.ago)
    today = Task.create!(title: "Today", due_date: Time.current)

    tasks = Task.ordered_by_due_date
    assert_equal [past, today, future], tasks.to_a
  end

  test "should filter completed tasks" do
    Task.delete_all
    completed = Task.create!(title: "Done", is_completed: true)
    uncompleted = Task.create!(title: "Todo", is_completed: false)

    assert_includes Task.completed, completed
    refute_includes Task.completed, uncompleted
  end

  test "should filter uncompleted tasks" do
    Task.delete_all
    completed = Task.create!(title: "Done", is_completed: true)
    uncompleted = Task.create!(title: "Todo", is_completed: false)

    assert_includes Task.uncompleted, uncompleted
    refute_includes Task.uncompleted, completed
  end

  test "should customize json output" do
    @task.save!
    json = @task.as_json

    assert_includes json.keys, "priority_text"
    refute_includes json.keys, "updated_at"
  end
end
