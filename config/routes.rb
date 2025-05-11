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
end