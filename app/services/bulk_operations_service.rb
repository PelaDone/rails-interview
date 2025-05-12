class BulkOperationsService
  class << self
    # Creación masiva de listas de tareas
    def bulk_create_todo_lists(todo_lists_attributes)
      todo_lists = []
      
      # Preparamos los objetos TodoList
      todo_lists_attributes.each do |attrs|
        todo_lists << TodoList.new(attrs)
      end
      
      # Importamos de forma masiva
      result = TodoList.import todo_lists, validate: true
      
      # Retornamos información sobre la operación
      {
        imported_count: result.ids.size,
        failed_instances: result.failed_instances,
        success: result.failed_instances.empty?
      }
    end

    # Actualización masiva de listas de tareas
    def bulk_update_todo_lists(todo_lists_attributes)
      todo_lists = []
      failed_instances = []
      
      todo_lists_attributes.each do |attrs|
        if attrs[:id].present?
          todo_list = TodoList.find_by(id: attrs[:id])
          if todo_list
            todo_list.assign_attributes(attrs.except(:id))
            todo_lists << todo_list
          else
            failed_instances << { id: attrs[:id], error: "TodoList not found" }
          end
        else
          failed_instances << { error: "ID is required for updates" }
        end
      end
      
      # Importamos con on_duplicate_key_update para actualizar registros existentes
      result = TodoList.import todo_lists, 
                              validate: true, 
                              on_duplicate_key_update: { columns: [:name] }
      
      # Añadimos cualquier instancia que falló durante la importación
      failed_instances += result.failed_instances
      
      {
        updated_count: result.ids.size,
        failed_instances: failed_instances,
        success: failed_instances.empty?
      }
    end

    # Creación masiva de items
    def bulk_create_items(items_attributes)
      items = []
      failed_instances = []
      
      items_attributes.each do |attrs|
        if attrs[:todo_list_id].present?
          # Verificamos que la todo_list exista
          if TodoList.exists?(attrs[:todo_list_id])
            items << Item.new(attrs)
          else
            failed_instances << { attributes: attrs, error: "TodoList not found" }
          end
        else
          failed_instances << { attributes: attrs, error: "todo_list_id is required" }
        end
      end
      
      result = Item.import items, validate: true
      
      # Añadimos cualquier instancia que falló durante la importación
      failed_instances += result.failed_instances
      
      {
        imported_count: result.ids.size,
        failed_instances: failed_instances,
        success: failed_instances.empty?
      }
    end

    # Actualización masiva de items
    def bulk_update_items(items_attributes)
      items = []
      failed_instances = []

      items_attributes.each do |attrs|
        if attrs[:id].present?
          item = Item.find_by(id: attrs[:id])
          if item
            item.assign_attributes(attrs.except(:id))
            items << item
          else
            failed_instances << { id: attrs[:id], error: "Item not found" }
          end
        else
          failed_instances << { error: "ID is required for updates" }
        end
      end
      
      result = Item.import items, 
                        validate: true, 
                        on_duplicate_key_update: { columns: [:description, :todo_list_id] }
      
      # Añadimos cualquier instancia que falló durante la importación
      failed_instances += result.failed_instances
      
      {
        updated_count: result.ids.size,
        failed_instances: failed_instances,
        success: failed_instances.empty?
      }
    end
    
    # Creación masiva de listas y sus items en una sola transacción
    def bulk_create_todo_lists_with_items(todo_lists_with_items)
      ActiveRecord::Base.transaction do
        todo_lists = []
        items_by_todo_list_index = {}
        
        # Primero creamos los todo_lists
        todo_lists_with_items.each_with_index do |list_data, index|
          todo_list = TodoList.new(name: list_data[:name])
          todo_lists << todo_list
          
          # Guardamos los items asociados para procesar después de la importación
          if list_data[:items].present?
            items_by_todo_list_index[index] = list_data[:items]
          end
        end
        
        # Importamos las listas
        todo_lists_result = TodoList.import todo_lists, validate: true
        
        if todo_lists_result.failed_instances.any?
          # Si alguna lista falla, abortamos toda la transacción
          raise ActiveRecord::Rollback, "Failed to create some TodoLists"
        end
        
        # Ahora procesamos los items usando los IDs de las listas recién creadas
        items = []
        items_by_todo_list_index.each do |list_index, items_data|
          todo_list_id = todo_lists_result.ids[list_index]
          
          items_data.each do |item_data|
            items << Item.new(
              description: item_data[:description],
              todo_list_id: todo_list_id
            )
          end
        end
        
        # Importamos los items
        items_result = Item.import items, validate: true
        
        if items_result.failed_instances.any?
          # Si algún item falla, abortamos toda la transacción
          raise ActiveRecord::Rollback, "Failed to create some Items"
        end
        
        {
          todo_lists_count: todo_lists_result.ids.size,
          items_count: items_result.ids.size,
          success: true
        }
      end
    rescue => e
      { error: e.message, success: false }
    end
  end
end