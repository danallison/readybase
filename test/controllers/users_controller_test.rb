require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def signin
    post '/api/v1/sessions', params: {
      username: @user.username,
      password: @password
    }, headers: @headers, as: :json
  end

  def signout
    delete '/api/v1/sessions', headers: @headers, as: :json
  end

  setup do
    app = App.first
    @headers = {'X-App-ID' => app.public_id }
    @user = users(:one)
    @user.app_id = app.id
    @password = SecureRandom.hex(4)
    @user.password = @password
    @user.save!
  end

  test "should get index" do
    signin
    get '/api/v1/users', headers: @headers, as: :json
    assert_response :success
    signout
  end

  test "should paginate index" do
    signin
    per_page = 1
    page = 1
    get "/api/v1/users?page=#{page}&per_page=#{per_page}", headers: @headers, as: :json
    json_response = JSON.parse(response.body)
    assert_equal(per_page, json_response['paging']['per_page'])
    assert_equal(per_page, json_response['data'].length)
    assert_equal(page, json_response['paging']['page'])
    signout
  end

  test "should create user when given email and password" do
    params = {
      email: 'thomas@readybase.org',
      password: SecureRandom.hex(10)
    }
    assert_difference('User.count') do
      post '/api/v1/users', headers: @headers, params: params, as: :json
    end
    assert_response 201
    user = JSON.parse(response.body)
    assert_equal(params[:email], user['email'])
    assert_equal(params[:email], user['username'])
  end

  test "should show user" do
    signin
    get "/api/v1/users/#{@user.unique_id}", headers: @headers, as: :json
    assert_response :success
    user = JSON.parse(response.body)
    assert_equal(@user.unique_id, user['id'])
    signout
  end

  test "should update user" do
    patch "/api/v1/users/#{@user.unique_id}", headers: @headers, params: { data: { foo: 1 } }, as: :json
    assert_response 200
  end

  # test "should destroy user" do
  #   assert_difference('User.count', -1) do
  #     delete "/api/v1/users/#{@user.unique_id}", headers: @headers, as: :json
  #   end
  #
  #   assert_response 204
  # end
end
