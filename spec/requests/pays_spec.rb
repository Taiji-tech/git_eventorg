require 'rails_helper'

RSpec.describe "Pays", type: :request do
  describe "cannoy access without login" do
    def cannot_access_without_login(path)
      get path
      expect(response).to have_http_status(302)
    end
    
    it "new_pay_path" do
      cannot_access_without_login(new_pay_path)
    end
    
    it "user_pays_hostnew_path" do
      cannot_access_without_login(user_pays_hostnew_path)
    end
    
    it "user_pays_hostinfo_path" do
      cannot_access_without_login(user_pays_hostinfo_path)
    end
    
    it "user_pays_confirm_card_path" do
      cannot_access_without_login(user_pays_confirm_card_path)
    end
    
    it "user_pays_profit_path" do
      cannot_access_without_login(user_pays_profit_path)
    end
    
    
  end
end
