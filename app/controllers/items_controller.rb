class ItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_item, only: [:edit, :update, :destroy, :show]

  # GET /items
  def index
    @items = Item.all
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # POST /items
  def create
    @item = @todo_list.items.new(item_params)

    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to items_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /items/id
  def show; end

  # GET /items/id
  def edit
    respond_to :html
  end

  # PATCH /items/id
  def update
    if @item.update(item_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_list_path(@todo_list) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /api/items
  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todo_list_path(@todo_list) }
    end
  end

  private

  def item_params
    params.require(:item).permit(:description, :completed, :todo_list_id)
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def set_item
    @item = @todo_list.items.find(params[:id])
  end
end