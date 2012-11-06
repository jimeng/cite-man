require 'test_helper'

class ConfigValuesControllerTest < ActionController::TestCase
  setup do
    @config_value = config_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:config_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create config_value" do
    assert_difference('ConfigValue.count') do
      post :create, :config_value => { :name => @config_value.name, :source_type => @config_value.source_type, :value => @config_value.value }
    end

    assert_redirected_to config_value_path(assigns(:config_value))
  end

  test "should show config_value" do
    get :show, :id => @config_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @config_value
    assert_response :success
  end

  test "should update config_value" do
    put :update, :id => @config_value, :config_value => { :name => @config_value.name, :source_type => @config_value.source_type, :value => @config_value.value }
    assert_redirected_to config_value_path(assigns(:config_value))
  end

  test "should destroy config_value" do
    assert_difference('ConfigValue.count', -1) do
      delete :destroy, :id => @config_value
    end

    assert_redirected_to config_values_path
  end
end
