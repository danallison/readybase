require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    app = App.first
    @headers = {'X-App-ID' => app.public_id }
    @user = users(:one)
    @user.app_id = app.id
    @user.save!
  end

  test "should get index" do
    get '/api/v1/users', headers: @headers, as: :json
    assert_response :success
  end

  test "should create user when given username and password" do
    assert_difference('User.count') do
      post '/api/v1/users', headers: @headers, params: {
        username: 'thomas',
        email: 'thomas@readybase.org',
        password: SecureRandom.hex(10)
      }, as: :json
    end
    assert_response 201
  end

  test "should show user" do
    get "/api/v1/users/#{@user.unique_id}", headers: @headers, as: :json
    assert_response :success
  end

  test "should update user" do
    patch "/api/v1/users/#{@user.unique_id}", headers: @headers, params: { data: { foo: 1 } }, as: :json
    assert_response 200
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete "/api/v1/users/#{@user.unique_id}", headers: @headers, as: :json
    end

    assert_response 204
  end
end
