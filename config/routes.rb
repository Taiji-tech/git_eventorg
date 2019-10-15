Rails.application.routes.draw do
  devise_for :users
  root 'events#index'
  resources :events do
   resources :reserves, only: [:create]
  end
  resources :users, only: [:show]
end
