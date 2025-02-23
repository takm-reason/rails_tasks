class TasksController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :uncomplete]
  before_action :set_tasks, only: [:index, :create, :update, :destroy, :complete, :uncomplete]

  def index
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
        format.turbo_stream
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: { errors: @task.errors }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('task_form', partial: 'form', locals: { task: @task }) }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_path, notice: 'タスクが更新されました。' }
        format.json { render json: @task }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @task.errors }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', partial: 'edit', locals: { task: @task }) }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクが削除されました。' }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  def complete
    @task.complete!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクを完了しました。' }
      format.json { render json: @task }
      format.turbo_stream
    end
  end

  def uncomplete
    @task.uncomplete!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: 'タスクを未完了に戻しました。' }
      format.json { render json: @task }
      format.turbo_stream
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_tasks
    case params[:sort]
    when 'priority'
      @tasks = Task.ordered_by_priority
    when 'due_date'
      @tasks = Task.ordered_by_due_date
    else
      @tasks = Task.order(created_at: :desc)
    end
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :priority)
  end
end
