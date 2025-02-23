module Api
  class TasksController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :set_task, only: [:show, :update, :destroy, :complete, :uncomplete]

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: 'リソースが見つかりませんでした' }, status: :not_found
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: 'パラメータが不正です', detail: e.message }, status: :bad_request
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

    def show
      render json: @task
    end

    def create
      task = Task.new(task_params)

      if task.save
        render json: task, status: :created
      else
        render json: { errors: task.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @task.update(task_params)
        render json: @task
      else
        render json: { errors: @task.errors }, status: :unprocessable_entity
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
      params.require(:task).permit(:title, :description, :due_date, :priority)
    end
  end
end