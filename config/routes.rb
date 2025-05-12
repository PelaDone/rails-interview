Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
    resources :items do
      member do
        put 'toogle'
      end
    end
  end

  resources :todo_lists, only: %i[index new create show], path: :todolists do
    resources :items
  end

  # Rutas para operaciones masivas
  post 'bulk/todo_lists', to: 'bulk_operations#create_todo_lists'
  put 'bulk/todo_lists', to: 'bulk_operations#update_todo_lists'
  post 'bulk/items', to: 'bulk_operations#create_items'
  put 'bulk/items', to: 'bulk_operations#update_items'
  post 'bulk/todo_lists_with_items', to: 'bulk_operations#create_todo_lists_with_items'
  
  # Ruta para verificar el estado de un job
  get 'job_status/:id', to: 'job_status#show'
end