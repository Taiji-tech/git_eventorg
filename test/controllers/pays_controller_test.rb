require 'test_helper'

class PaysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get pays_new_url
    assert_response :success
  end

end
