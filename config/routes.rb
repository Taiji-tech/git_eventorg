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
  
# ユーザー情報関連
  get "user/profile",  to: "users#profile"
  get "user/edit",     to: "users#edit"
  patch "user/update", to: "users#update"

# 支払い関連
  resources :pays, only: [:new, :create]
  get "user/pays/confirm_card",  to: "pays#confirmCard"
  get "user/pays/edit_card",     to: "pays#editCard"
  get "user/pays/confirm",       to: "pays#confirm"
  get "user/pays/hostnew",       to: "pays#hostNew"
  post "user/pays/host"  ,       to: "pays#hostCreate"
  
  
end
