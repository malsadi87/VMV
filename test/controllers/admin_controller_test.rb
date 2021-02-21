require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_index_url
    assert_response :success
  end

  test "should get dashboard" do
    get admin_dashboard_url
    assert_response :success
  end

  test "should get elections" do
    get admin_elections_url
    assert_response :success
  end

  test "should get startElection" do
    get admin_startElection_url
    assert_response :success
  end

  test "should get newElection" do
    get admin_newElection_url
    assert_response :success
  end

  test "should get sendVerifiactionParams" do
    get admin_sendVerifiactionParams_url
    assert_response :success
  end

  test "should get uploadPreElectionToBC" do
    get admin_uploadPreElectionToBC_url
    assert_response :success
  end

end
