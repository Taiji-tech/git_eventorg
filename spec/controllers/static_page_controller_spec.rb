require 'rails_helper'

RSpec.describe StaticPageController, type: :controller do

  describe "GET #contact" do
    it "returns http success" do
      get :contact
      expect(response).to have_http_status(:success)
    end
  end

end
