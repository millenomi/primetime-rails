require 'test_helper'

class YoutubesControllerTest < ActionController::TestCase
  setup do
    @youtube = youtubes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:youtubes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create youtube" do
    assert_difference('Youtube.count') do
      post :create, :youtube => @youtube.attributes
    end

    assert_redirected_to youtube_path(assigns(:youtube))
  end

  test "should show youtube" do
    get :show, :id => @youtube.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @youtube.to_param
    assert_response :success
  end

  test "should update youtube" do
    put :update, :id => @youtube.to_param, :youtube => @youtube.attributes
    assert_redirected_to youtube_path(assigns(:youtube))
  end

  test "should destroy youtube" do
    assert_difference('Youtube.count', -1) do
      delete :destroy, :id => @youtube.to_param
    end

    assert_redirected_to youtubes_path
  end
end
