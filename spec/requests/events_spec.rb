require 'rails_helper'

RSpec.describe "Events", type: :request do
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
