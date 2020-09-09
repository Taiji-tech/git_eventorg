require 'rails_helper'

RSpec.describe "Events", type: :request do
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
  
  
  describe "Top page" do
    it "not login user" do
      get root_path
      expect(response).to have_http_status(200)
    end
    
    it "login user" do
      user = create(:user)
      sign_in user
      get root_path
      expect(response).to have_http_status(200)
    end
  end
end
