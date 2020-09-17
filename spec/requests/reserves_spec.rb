require 'rails_helper'

RSpec.describe "Reserves", type: :request do
  include Devise::Test::IntegrationHelpers
  
  describe "cannot access without login" do
    it "user_reserved_path" do
      get user_reserved_path
      expect(response).to have_http_status(302)
    end
  end
  
  describe "user_reserved_path" do
    before do
      user = create(:user)
      sign_in user
    end
    
    it "get user_reserved_path" do
      get user_reserved_path
      expect(response).to have_http_status(200)
    end
  end
  
  describe "" do
      
  end
end
