Rails.application.routes.draw do
  devise_for :users
  root 'events#index'
  resources :events do
   resources :reserves, only: [:create]
  end
  resources :users, only: [:show]
  
  delete '/events/:event_id/reserves' => 'reserves#destroy'
  
  post '/events/new' => 'events#create'

end
