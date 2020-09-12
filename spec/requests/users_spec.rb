require 'rails_helper'

RSpec.describe "Users", type: :request do
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
end
