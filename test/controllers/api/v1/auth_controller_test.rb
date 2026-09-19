require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "registers an organization and owner" do
    assert_difference("Organization.count", 1) do
      assert_difference("User.count", 1) do
        post "/api/v1/auth/register", params: {
          organization: {
            name: "Registration Test Store",
            slug: "registration-test-store"
          },
          user: {
            first_name: "Pierre",
            last_name: "Celestin",
            email: "pierre@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert body["token"].present?
    assert_equal "pierre@example.com", body["user"]["email"]
    assert_equal "owner", body["user"]["role"]
    assert_equal "registration-test-store", body["organization"]["slug"]
  end

  test "normalizes user email during registration" do
    post "/api/v1/auth/register", params: {
      organization: {
        name: "Email Normalization Store",
        slug: "email-normalization-test-store"
      },
      user: {
        first_name: "Pierre",
        last_name: "Celestin",
        email: "  PIERRE@EXAMPLE.COM  ",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "pierre@example.com", body["user"]["email"]
  end

  test "rejects invalid registration data" do
    assert_no_difference ["Organization.count", "User.count"] do
      post "/api/v1/auth/register", params: {
        organization: {
          name: "",
          slug: ""
        },
        user: {
          first_name: "",
          last_name: "",
          email: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "Validation failed", body["error"]
    assert_kind_of Array, body["errors"]
    assert body["errors"].present?
    assert_includes body["errors"], "Name can't be blank"
  end

  test "logs in with valid credentials" do
    organization = organizations(:acme)
    user = users(:owner)

    post "/api/v1/auth/login", params: {
      organization_slug: organization.slug,
      email: user.email,
      password: "password123"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert body["token"].present?
    assert_equal user.email, body["user"]["email"]
    assert_equal organization.slug, body["organization"]["slug"]
  end

  test "rejects invalid credentials" do
    organization = organizations(:acme)
    user = users(:owner)

    post "/api/v1/auth/login", params: {
      organization_slug: organization.slug,
      email: user.email,
      password: "wrong-password"
    }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal(
      "Invalid email, password, or organization",
      body["error"]
    )
  end

  test "returns current user with valid token" do
    organization = organizations(:acme)
    user = users(:owner)

    token = JwtService.encode(user)

    get "/api/v1/auth/me", headers: {
      "Authorization" => "Bearer #{token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal user.id, body["user"]["id"]
    assert_equal user.email, body["user"]["email"]
    assert_equal organization.slug, body["organization"]["slug"]
  end

  test "rejects missing token" do
    get "/api/v1/auth/me"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects invalid token" do
    get "/api/v1/auth/me", headers: {
      "Authorization" => "Bearer invalid-token"
    }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Invalid authorization token", body["error"]
  end
end