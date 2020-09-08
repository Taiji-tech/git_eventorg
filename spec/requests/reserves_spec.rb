require 'rails_helper'

RSpec.describe "Reserves", type: :request do
  describe "GET /reserves" do
    it "works! (now write some real specs)" do
      get reserves_path
      expect(response).to have_http_status(200)
    end
  end
end
