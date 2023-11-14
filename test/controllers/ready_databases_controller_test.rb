require "test_helper"

class ReadyDatabasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ready_database = ready_databases(:one)
  end

  test "should get index" do
    get ready_databases_url, as: :json
    assert_response :success
  end

  test "should create ready_database" do
    assert_difference("ReadyDatabase.count") do
      post ready_databases_url, params: { ready_database: { custom_id: @ready_database.custom_id, data: @ready_database.data } }, as: :json
    end

    assert_response :created
  end

  test "should show ready_database" do
    get ready_database_url(@ready_database), as: :json
    assert_response :success
  end

  test "should update ready_database" do
    patch ready_database_url(@ready_database), params: { ready_database: { custom_id: @ready_database.custom_id, data: @ready_database.data } }, as: :json
    assert_response :success
  end

  test "should destroy ready_database" do
    assert_difference("ReadyDatabase.count", -1) do
      delete ready_database_url(@ready_database), as: :json
    end

    assert_response :no_content
  end
end
