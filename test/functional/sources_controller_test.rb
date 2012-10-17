require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
  setup do
    @source = sources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create source" do
    assert_difference('Source.count') do
      post :create, :source => { :client_id => @source.client_id, :client_key => @source.client_key, :client_secret => @source.client_secret, :client_type => @source.client_type, :name => @source.name, :person_id => @source.person_id, :provider => @source.provider, :uid => @source.uid }
    end

    assert_redirected_to source_path(assigns(:source))
  end

  test "should show source" do
    get :show, :id => @source
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @source
    assert_response :success
  end

  test "should update source" do
    put :update, :id => @source, :source => { :client_id => @source.client_id, :client_key => @source.client_key, :client_secret => @source.client_secret, :client_type => @source.client_type, :name => @source.name, :person_id => @source.person_id, :provider => @source.provider, :uid => @source.uid }
    assert_redirected_to source_path(assigns(:source))
  end

  test "should destroy source" do
    assert_difference('Source.count', -1) do
      delete :destroy, :id => @source
    end

    assert_redirected_to sources_path
  end
end
