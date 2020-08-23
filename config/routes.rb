Rails.application.routes.draw do
  root "events#top"
  
  devise_for :users
  
#   ユーザー管理関連
  resources :users, only: [:show]
  
# イベント管理関連  
  get "events/confirm",  to: "events#confirm"
  
  resources :events do
    resources :reserves, only: [:create]
    post "/create_with_resistration", to: "reserves#createWithResistration" 
  end
  
  
  
end
