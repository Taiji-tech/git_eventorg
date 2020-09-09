require 'rails_helper'

RSpec.describe "Reserves", type: :request do
  describe "cannot access without login" do
    it "user_reserved_path" do
      get user_reserved_path
      expect(response).to have_http_status(302)
    end
  end
end
