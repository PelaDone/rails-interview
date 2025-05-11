module Api
  class ItemsController < ApiController
    before_action :set_item, only: [:update, :destroy, :toogle]

    # GET /api/items
    def index
      @items = Item.all
    end

    # POST /api/items
    def create
      @item = Item.new(item_params)
      if @item.save
        render json: @item, status: :created
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end

    # PATCH /api/items
    def update
      if @item.update(item_params)
        render json: @item
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/items
    def destroy
      @item.delete
    end

    # PUT /api/items/:id/toogle
    def toogle
      @item.toggle!(:completed)
    end

    private

    # Busca el item por :id antes de update
    def set_item
      @item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Item no encontrado" }, status: :not_found
    end

    # Filtra y permite los parámetros seguros
    def item_params
      params.require(:todo_list).permit(:description, :completed, :todo_list_id)
    end
  end
end
