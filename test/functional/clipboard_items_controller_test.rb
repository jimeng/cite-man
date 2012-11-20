require 'test_helper'

class ClipboardItemsControllerTest < ActionController::TestCase
  setup do
    @clipboard_item = clipboard_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clipboard_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create clipboard_item" do
    assert_difference('ClipboardItem.count') do
      post :create, :clipboard_item => { :citation => @clipboard_item.citation }
    end

    assert_redirected_to clipboard_item_path(assigns(:clipboard_item))
  end

  test "should show clipboard_item" do
    get :show, :id => @clipboard_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @clipboard_item
    assert_response :success
  end

  test "should update clipboard_item" do
    put :update, :id => @clipboard_item, :clipboard_item => { :citation => @clipboard_item.citation }
    assert_redirected_to clipboard_item_path(assigns(:clipboard_item))
  end

  test "should destroy clipboard_item" do
    assert_difference('ClipboardItem.count', -1) do
      delete :destroy, :id => @clipboard_item
    end

    assert_redirected_to clipboard_items_path
  end
end
