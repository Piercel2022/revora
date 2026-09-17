require "test_helper"

class Api::V1::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "returns the current user's organization" do
    user = users(:owner)
    organization = organizations(:acme)
    token = JwtService.encode(user)

    get "/api/v1/organizations/#{organization.id}", headers: {
      "Authorization" => "Bearer #{token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal organization.id, body["id"]
    assert_equal organization.slug, body["slug"]
  end

  test "forbids access to another organization" do
    user = users(:owner)
    organization = organizations(:another)
    token = JwtService.encode(user)

    get "/api/v1/organizations/#{organization.id}", headers: {
      "Authorization" => "Bearer #{token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated access" do
    organization = organizations(:acme)

    get "/api/v1/organizations/#{organization.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end
end