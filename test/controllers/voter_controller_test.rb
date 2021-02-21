require 'test_helper'

class VoterControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get voter_login_url
    assert_response :success
  end

  test "should get elections" do
    get voter_elections_url
    assert_response :success
  end

  test "should get ballot" do
    get voter_ballot_url
    assert_response :success
  end

  test "should get result" do
    get voter_result_url
    assert_response :success
  end

  test "should get verificationResult" do
    get voter_verificationResult_url
    assert_response :success
  end

  test "should get summary" do
    get voter_summary_url
    assert_response :success
  end

end
