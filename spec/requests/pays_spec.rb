require 'rails_helper'

RSpec.describe "Pays", type: :request do
  include Devise::Test::IntegrationHelpers
  
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
  
  describe "bank account registration" do
    before do 
      user = create(:user)
      sign_in user
    end
    
    it "get user_pays_hostnew_path" do
      get user_pays_hostnew_path
      expect(response).to have_http_status(200)
    end
    
    it "empty bank info" do
      post user_pays_host_path, params: { bank_code: "", bank_branch_code: "", bank_account_type: "普通", bank_account_number: "", bank_account_holder_name: "" }
      expect(response.body).to include '空欄の項目があります。すべて入力してください'
    end
    
    it "success bank account registration" do
      post user_pays_host_path, params: { bank_code: "0009", bank_branch_code: "015", bank_account_type: "普通", bank_account_number: "1234567", bank_account_holder_name: "YUI ARAGAKI" }
      expect(response).to redirect_to user_pays_hostinfo_path
    end
  end
  
  describe "edit bank account infomation" do
    before do
      user = create(:user)
      sign_in user
      post user_pays_host_path, params: { bank_code: "0009", bank_branch_code: "015", bank_account_type: "普通", bank_account_number: "1234567", bank_account_holder_name: "YUI ARAGAKI" }
    end
    
    it "empty bank info" do
      post user_pays_hostupdate_path, params: { bank_code: "", bank_branch_code: "", bank_account_type: "普通", bank_account_number: "", bank_account_holder_name: "" }
      expect(response.body).to include '空欄の項目があります。すべて入力してください'
    end
    
    it "spec_name" do
      post user_pays_hostupdate_path, params: { bank_code: "0010", bank_branch_code: "015", bank_account_type: "普通", bank_account_number: "1234567", bank_account_holder_name: "YUI ARAGAKI" }
      expect(response).to redirect_to user_pays_hostinfo_path
    end
  end
end
