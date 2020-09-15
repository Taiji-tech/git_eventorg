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
  resources :reserves, only: [:destroy]
  get "reserves/:id/cancel",    to: "reserves#cancel"
  get "user/reserved",          to: "reserves#reserved"
  
  
# ユーザー情報関連
  get "user/profile",       to: "users#profile"
  get "user/edit",          to: "users#edit"
  patch "user/update",      to: "users#update"
  patch "user/update_pass", to: "users#updatePass"
  post "passwords",         to: "users#resetPass"

# 支払い関連
  resources :pays, only: [:new, :create]
  get "user/pays/confirm_card",           to: "pays#confirmCard"
  get "user/pays/edit_card",              to: "pays#editCard"
  post "user/pays/update_card",           to: "pays#updateCard"
  get "user/pays/confirm",                to: "pays#confirm"
  get "user/pays/hostnew",                to: "pays#hostNew"
  post "user/pays/host"  ,                to: "pays#hostCreate"
  get "user/pays/hostinfo" ,              to: "pays#hostInfo"
  get "user/pays/hostedit",               to: "pays#hostEdit"
  post "user/pays/hostupdate",            to: "pays#hostUpdate"
  get "pays/new_withoutresistration",     to: "pays#newWithoutResistration"
  post "pays/create_withoutresistration", to: "pays#createWithoutResistration"
  get "user/pays/profit",                 to: "pays#profit"
end
