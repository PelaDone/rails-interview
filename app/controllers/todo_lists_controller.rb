class TodoListsController < ApplicationController
  # GET /todolists
  def index
    @todo_lists = TodoList.all
  end

  # GET /todolists/new
  def new
    @todo_list = TodoList.new
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/id
  def show
    @todo_list = TodoList.find(params[:id])
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end
end