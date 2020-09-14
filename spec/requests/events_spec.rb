require 'rails_helper'

RSpec.describe "Events", type: :request do
  include Devise::Test::IntegrationHelpers
  
  describe "can access witout login" do
    def can_access_without_login(path)
      get path
      expect(response).to have_http_status(200)
    end
    
    it "root_path" do
      can_access_without_login(root_path)
    end
  end
  
  describe "cannot access without login" do
    def cannot_access_without_login(path)
      get path
      expect(response).to have_http_status(302)
    end
    
    it "new_event_path" do
      cannot_access_without_login(new_event_path)
    end
    
    it "events_confirm_path" do
      cannot_access_without_login(events_confirm_path)
    end
  end
  
  describe "can access with login" do
    def can_access_with_login(path)
      user = create(:user)
      sign_in user
      get path
      expect(response).to have_http_status(200)
    end
    
    it "root_path" do
      can_access_with_login(root_path)
    end

    it "new_event_path" do
      can_access_with_login(events_confirm_path)
    end
  end
  
  describe "new_event_path with login" do
    it "before bank account is resistered" do
      user = create(:user)
      sign_in user
      get new_event_path
      expect(response).to have_http_status(302)
    end
  
    it "after bank account is resistered" do
      user = create(:user)
      tenant = create(:tenant)
      sign_in user
      get new_event_path
      expect(response).to have_http_status(200)
    end
  end
  
  # イベントの作成
  describe "create event" do
    before do
      user = create(:user)
      tenant = create(:tenant)
      sign_in user
    end
    
    it "empty title" do
      post events_path, params: { event: { title: "", start_date: "", "start_time(1i)": "2020", "start_time(2i)": "9", "start_time(3i)": "12",
                                  "start_time(4i)": "10", "start_time(5i)": "30", content: "", venue: "", venue_pass: "", 
                                  capacity: "", price: "", img: "" } }
      expect(response.body).to include 'タイトルを入力してください'
      expect(response.body).to include '開催日時を入力してください'
      expect(response.body).to include 'イベント内容を入力してください'
      expect(response.body).to include 'Zoom IDを入力してください'
      expect(response.body).to include 'Zoom Passwordを入力してください'
      expect(response.body).to include '参加費を入力してください'
      expect(response.body).to include '定員を入力してください'
      expect(response.body).to include '画像を入力してください'
      expect(response).to have_http_status(200)
    end
    
    it "empty start_date" do
      post events_path, params: { event: { title: "タイトル", start_date: "2020-1-1", "start_time(1i)": "2020", "start_time(2i)": "9", "start_time(3i)": "12",
                                  "start_time(4i)": "10", "start_time(5i)": "30", content: "イベント内容", venue: "https://www.zoom.com", venue_pass: "123456", 
                                  capacity: "10", price: "1000", img: "imgfile" } }
      expect(response).to have_http_status(200)
      expect(response).to redirect_to events_confirm_path
    end
  end
  
  # イベントの削除
  describe "delete event" do
    before do
      user = create(:user)
      tenant = create(:tenant)
      sign_in user  
    end
  
  end
  
  
end
