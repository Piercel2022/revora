require "test_helper"

class Api::V1::ProfileControllerTest < ActionDispatch::IntegrationTest
  test "returns current user and organization with valid token" do
    user = users(:owner)
    organization = organizations(:acme)
    token = JwtService.encode(user)

    get "/api/v1/profile", headers: {
      "Authorization" => "Bearer #{token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal user.id, body["user"]["id"]
    assert_equal user.email, body["user"]["email"]
    assert_equal user.role, body["user"]["role"]
    assert_equal organization.id, body["organization"]["id"]
    assert_equal organization.slug, body["organization"]["slug"]
  end

  test "rejects request without token" do
    get "/api/v1/profile"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects request with invalid token" do
    get "/api/v1/profile", headers: {
      "Authorization" => "Bearer invalid-token"
    }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Invalid authorization token", body["error"]
  end

  test "rejects request with malformed authorization header" do
    get "/api/v1/profile", headers: {
      "Authorization" => "Token invalid-token"
    }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end
end
