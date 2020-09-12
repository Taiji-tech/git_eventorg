require 'rails_helper'

RSpec.describe "Users", type: :request do
  include Devise::Test::IntegrationHelpers
  
  describe "cannoy access without login" do
    def cannot_access_without_login(path)
      get path
      expect(response).to have_http_status(302)
    end
    
    it "user_edit_path" do
      cannot_access_without_login(user_edit_path)
    end
    
    it "user_profile_path" do
      cannot_access_without_login(user_profile_path)
    end
  end
  
  # ユーザー登録
  describe "new_resistration_path" do
    it "empty nickname" do
      post user_registration_path, params: { user: {nickname: "", email: "abc@gmail.com", password: "123456", password_confirmation: "123456" }}
      expect(response.body).to include 'ニックネームを入力してください'
    end
    
    it "get user_signup_path" do
      get new_user_registration_path
      expect(response).to have_http_status(200)
    end
    
    it "empty email" do
      post user_registration_path, params: { user: {nickname: "nickname", email: "", password: "123456", password_confirmation: "123456" }}
      expect(response.body).to include 'メールアドレスを入力してください'
    end
    
    it "wrong email type" do
      post user_registration_path, params: { user: {nickname: "nickname", email: "abc", password: "123456", password_confirmation: "123456" }}
      expect(response.body).to include 'メールアドレスは有効でありません'
    end
    
    it "empty password" do
      post user_registration_path, params: { user: {nickname: "nickname", email: "abc@gmail.com", password: "", password_confirmation: "" }}
      expect(response.body).to include 'パスワードを入力してください'
    end
    
    it "empty password" do
      post user_registration_path, params: { user: {nickname: "nickname", email: "abc@gmail.com", password: "", password_confirmation: "123456" }}
      expect(response.body).to include 'パスワードを入力してください'
      expect(response.body).to include '確認用パスワードとパスワードの入力が一致しません'
    end
    
    it "success" do
      post user_registration_path, params: { user: {nickname: "nickname", email: "abc@gmail.com", password: "123456", password_confirmation: "123456" }}
      expect(response).to have_http_status(302)
    end
  end
  
  # ログイン
  describe "new_user_session_path" do
    before do
      user = create(:user)  
    end
    
    it "get user_signup_path" do
      get new_user_session_path
      expect(response).to have_http_status(200)
    end
    
    it "empty email" do
      post user_session_path, params: { user: {email: "", password: "123456"}}
      expect(response.body).to include 'ログイン'
    end
    
    it "empty password" do
      post user_session_path, params: { user: {email: "test@gmail.com", password: ""}}
      expect(response.body).to include 'ログイン'
    end
    
    it "wrong password" do
      post user_session_path, params: { user: {email: "test@gmail.com", password: "1234567"}}
      expect(response.body).to include 'ログイン'
    end
    
    it "success" do
      post user_session_path, params: { user: {email: "test@gmail.com", password: "123456"}}
      expect(response).to have_http_status(302)
    end
  end
  
  
  # パスワード忘れ
  describe "forget_password" do
    before do
      user = create(:user)  
    end
    
    it "get new_user_password_path" do
      get new_user_password_path
      expect(response).to have_http_status(200)
    end
    
    it "input email" do
      post user_password_path, params: { user: {email: "test2@gmail.com"}}
      expect(response.body).to include 'メールアドレスは見つかりませんでした。'
    end
    
    it "input email" do
      post user_password_path, params: { user: {email: "test@gmail.com"}}
      expect(response).to have_http_status(302)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end
  
  # ユーザー情報編集
  describe "user edit" do
    before do
      user = create(:user)
      sign_in user
    end
    
    it "get user_edit_path" do
      get user_edit_path
      expect(response).to have_http_status(200)
    end
    
    it "update path" do
      patch user_update_path, params: { user: {nickname: "test1", email: "test@gmail.com", current_password: "123456"}}
      expect(response).to redirect_to user_edit_path
    end
  end
  
  # パスワード変更
  describe "user password edit" do
    before do
      user = create(:user)
      sign_in user
    end
    
    it "update path" do
      patch user_update_pass_path, params: { user: {current_password: "123456", password: "1234567", password_confirmation: "1234567"}}
      expect(response).to redirect_to user_edit_path
    end
  end
end
