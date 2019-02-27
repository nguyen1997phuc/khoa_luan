Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root "static_pages#index"
  resources :categories, only: %i(show) 
end
