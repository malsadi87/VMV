require 'test_helper'

class ElectionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get election_index_url
    assert_response :success
  end

  test "should get view" do
    get election_view_url
    assert_response :success
  end

  test "should get uploads" do
    get election_uploads_url
    assert_response :success
  end

end
