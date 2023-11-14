require "test_helper"

class ReadyResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ready_resource = ready_resources(:one)
  end

  test "should get index" do
    get ready_resources_url, as: :json
    assert_response :success
  end

  test "should create ready_resource" do
    assert_difference("ReadyResource.count") do
      post ready_resources_url, params: { ready_resource: { belongs_to: @ready_resource.belongs_to, custom_id: @ready_resource.custom_id, data: @ready_resource.data, ready_database_id: @ready_resource.ready_database_id, resource_type: @ready_resource.resource_type } }, as: :json
    end

    assert_response :created
  end

  test "should show ready_resource" do
    get ready_resource_url(@ready_resource), as: :json
    assert_response :success
  end

  test "should update ready_resource" do
    patch ready_resource_url(@ready_resource), params: { ready_resource: { belongs_to: @ready_resource.belongs_to, custom_id: @ready_resource.custom_id, data: @ready_resource.data, ready_database_id: @ready_resource.ready_database_id, resource_type: @ready_resource.resource_type } }, as: :json
    assert_response :success
  end

  test "should destroy ready_resource" do
    assert_difference("ReadyResource.count", -1) do
      delete ready_resource_url(@ready_resource), as: :json
    end

    assert_response :no_content
  end
end
