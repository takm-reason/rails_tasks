module Api
  class TasksController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :set_task, only: [:show, :update, :destroy, :complete, :uncomplete]

    rescue_from ActiveRecord::RecordNotFound do |e|
      error_response('リソースが見つかりませんでした', :not_found)
    end

    rescue_from ActionController::ParameterMissing do |e|
      error_response('パラメータが不正です', :bad_request, detail: e.message)
    end

    rescue_from ArgumentError do |e|
      if e.message.include?('priority')
        error_response(
          'プライオリティの値が不正です',
          :unprocessable_entity,
          errors: {
            priority: ["は'low', 'medium', 'high'のいずれかを指定してください"]
          }
        )
      else
        raise e
      end
    end

    def index
      tasks = case params[:sort]
              when 'priority'
                Task.ordered_by_priority
              when 'due_date'
                Task.ordered_by_due_date
              else
                Task.order(created_at: :desc)
              end

      render json: tasks
    end

    def completed
      tasks = Task.completed.order(completed_at: :desc)
      render json: tasks
    end

    def show
      render json: @task
    end

    def create
      task = Task.new(task_params)

      if task.save
        render json: task, status: :created
      else
        error_response(
          'タスクの作成に失敗しました',
          :unprocessable_entity,
          errors: task.errors
        )
      end
    end

    def update
      if @task.update(task_params)
        render json: @task
      else
        error_response(
          'タスクの更新に失敗しました',
          :unprocessable_entity,
          errors: @task.errors
        )
      end
    end

    def destroy
      @task.destroy
      head :no_content
    end

    def complete
      @task.complete!
      render json: @task
    end

    def uncomplete
      @task.uncomplete!
      render json: @task
    end

    private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      permitted_params = params.require(:task).permit(:title, :description, :due_date, :priority)
      if permitted_params[:priority].present? && !Task.priorities.keys.include?(permitted_params[:priority])
        raise ArgumentError, "invalid priority"
      end
      permitted_params
    end

    def error_response(message, status, extra = {})
      response = { message: message }
      response.merge!(extra)
      render json: response, status: status
    end
  end
end