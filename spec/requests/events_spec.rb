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
  
  
  
  
  
end
