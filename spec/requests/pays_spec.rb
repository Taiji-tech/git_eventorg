require 'rails_helper'

RSpec.describe "Pays", type: :request do
  describe "GET /pays" do
    it "works! (now write some real specs)" do
      get pays_path
      expect(response).to have_http_status(200)
    end
  end
end
