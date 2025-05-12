class BulkOperationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create_todo_lists, :update_todo_lists, :create_items, :update_items, :create_todo_lists_with_items]
  
  # POST /bulk/todo_lists
  def create_todo_lists
    # Verifica si debe ejecutarse en background
    if params[:async] == 'true'
      job = BulkTodoListsJob.perform_later('create', todo_lists_params, params[:callback_url])
      render json: { 
        message: "Todo lists creation job enqueued", 
        job_id: job.job_id 
      }, status: :accepted
    else
      # Ejecución síncrona
      result = BulkOperationsService.bulk_create_todo_lists(todo_lists_params)
      
      if result[:success]
        render json: { message: "Successfully imported #{result[:imported_count]} todo lists" }, status: :created
      else
        render json: { message: "Some todo lists could not be imported", errors: result[:failed_instances] }, status: :unprocessable_entity
      end
    end
  end
  
  # PUT /bulk/todo_lists
  def update_todo_lists
    # Verifica si debe ejecutarse en background
    if params[:async] == 'true'
      job = BulkTodoListsJob.perform_later('update', todo_lists_update_params, params[:callback_url])
      render json: { 
        message: "Todo lists update job enqueued", 
        job_id: job.job_id 
      }, status: :accepted
    else
      # Ejecución síncrona
      result = BulkOperationsService.bulk_update_todo_lists(todo_lists_update_params)
      
      if result[:success]
        render json: { message: "Successfully updated #{result[:updated_count]} todo lists" }
      else
        render json: { message: "Some todo lists could not be updated", errors: result[:failed_instances] }, status: :unprocessable_entity
      end
    end
  end
  
  # POST /bulk/items
  def create_items
    # Verifica si debe ejecutarse en background
    if params[:async] == 'true'
      job = BulkItemsJob.perform_later('create', items_params, params[:callback_url])
      render json: { 
        message: "Items creation job enqueued", 
        job_id: job.job_id 
      }, status: :accepted
    else
      # Ejecución síncrona
      result = BulkOperationsService.bulk_create_items(items_params)
      
      if result[:success]
        render json: { message: "Successfully imported #{result[:imported_count]} items" }, status: :created
      else
        render json: { message: "Some items could not be imported", errors: result[:failed_instances] }, status: :unprocessable_entity
      end
    end
  end
  
  # PUT /bulk/items
  def update_items
    # Verifica si debe ejecutarse en background
    if params[:async] == 'true'
      job = BulkItemsJob.perform_later('update', items_update_params, params[:callback_url])
      render json: { 
        message: "Items update job enqueued", 
        job_id: job.job_id 
      }, status: :accepted
    else
      # Ejecución síncrona
      result = BulkOperationsService.bulk_update_items(items_update_params)
      
      if result[:success]
        render json: { message: "Successfully updated #{result[:updated_count]} items" }
      else
        render json: { message: "Some items could not be updated", errors: result[:failed_instances] }, status: :unprocessable_entity
      end
    end
  end
  
  # POST /bulk/todo_lists_with_items
  def create_todo_lists_with_items
    # Verifica si debe ejecutarse en background
    if params[:async] == 'true'
      job = BulkTodoListsWithItemsJob.perform_later(todo_lists_with_items_params, params[:callback_url])
      render json: { 
        message: "Todo lists with items creation job enqueued", 
        job_id: job.job_id 
      }, status: :accepted
    else
      # Ejecución síncrona
      result = BulkOperationsService.bulk_create_todo_lists_with_items(todo_lists_with_items_params)
      
      if result[:success]
        render json: { 
          message: "Successfully imported #{result[:todo_lists_count]} todo lists with #{result[:items_count]} items"
        }, status: :created
      else
        render json: { message: "Operation failed", error: result[:error] }, status: :unprocessable_entity
      end
    end
  end
  
  private
  
  def todo_lists_params
    params.require(:todo_lists).map do |todo_list|
      todo_list.permit(:name)
    end
  end
  
  def todo_lists_update_params
    params.require(:todo_lists).map do |todo_list|
      todo_list.permit(:id, :name)
    end
  end
  
  def items_params
    params.require(:items).map do |item|
      item.permit(:todo_list_id, :description)
    end
  end
  
  def items_update_params
    params.require(:items).map do |item|
      item.permit(:id, :todo_list_id, :description)
    end
  end
  
  def todo_lists_with_items_params
    params.require(:todo_lists).map do |todo_list|
      items = todo_list[:items]&.map { |item| item.permit(:description).to_h } || []
      
      {
        name: todo_list[:name],
        items: items
      }
    end
  end
end