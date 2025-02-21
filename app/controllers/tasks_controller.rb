class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :uncomplete]

  def index
    @tasks = Task.all
    
    case params[:sort]
    when 'priority'
      @tasks = @tasks.ordered_by_priority
    when 'due_date'
      @tasks = @tasks.ordered_by_due_date
    else
      @tasks = @tasks.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.json { render json: @tasks }
      format.turbo_stream
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream { render :edit }
    end
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path, notice: 'タスクが作成されました。' }
        format.json { render json: @task, status: :created }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        @tasks = Task.order(created_at: :desc)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('tasks', partial: 'tasks/index', locals: { tasks: @tasks }),
            turbo_stream.update('modal', '')
          ]
        end
        format.html { redirect_to tasks_path, notice: 'タスクが更新されました。' }
        format.json { render json: @task }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            'modal',
            partial: 'tasks/edit',
            locals: { task: @task }
          )
        }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクが削除されました。' }
      format.json { head :no_content }
      format.turbo_stream { 
        @tasks = Task.order(created_at: :desc)
        render turbo_stream: turbo_stream.update('tasks', partial: 'tasks/index', locals: { tasks: @tasks })
      }
    end
  end

  def complete
    @task.complete!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクを完了しました。' }
      format.json { render json: @task }
      format.turbo_stream {
        @tasks = Task.order(created_at: :desc)
        render turbo_stream: turbo_stream.update('tasks', partial: 'tasks/index', locals: { tasks: @tasks })
      }
    end
  end

  def uncomplete
    @task.uncomplete!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクを未完了に戻しました。' }
      format.json { render json: @task }
      format.turbo_stream {
        @tasks = Task.order(created_at: :desc)
        render turbo_stream: turbo_stream.update('tasks', partial: 'tasks/index', locals: { tasks: @tasks })
      }
    end
  end

  def completed
    @tasks = Task.where(is_completed: true).order(completed_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @tasks }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :priority)
  end
end
