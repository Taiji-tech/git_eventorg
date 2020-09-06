# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Events', type: :request do
  describe "get root_path" do
    it "unnone user" do
      get root_path
      expect(response).to have_http_status(:success)
    end  
  end
end