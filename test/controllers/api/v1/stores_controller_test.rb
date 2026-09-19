require "test_helper"

class Api::V1::StoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_store = stores(:acme_store)
    @another_store = stores(:another_store)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only stores from the current user's organization" do
    get "/api/v1/stores", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    ids = body.map { |store| store["id"] }

    assert_includes ids, @acme_store.id
    refute_includes ids, @another_store.id
  end

  test "shows a store from the current user's organization" do
    get "/api/v1/stores/#{@acme_store.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_store.id, body["id"]
    assert_equal @acme_store.name, body["name"]
  end

  test "returns not found for a missing store" do
    get "/api/v1/stores/00000000-0000-0000-0000-000000000000", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "forbids access to a store from another organization" do
    get "/api/v1/stores/#{@another_store.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/stores"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/stores/#{@acme_store.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create a store" do
    assert_difference("Store.count", 1) do
      post "/api/v1/stores",
        params: {
          store: {
            name: "New Acme Store",
            platform: "shopify",
            external_id: "shopify-acme-002",
            domain: "new-acme-store.myshopify.com",
            currency: "EUR",
            timezone: "Europe/Paris",
            status: "active"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New Acme Store", body["name"]
    assert_equal @owner.organization_id, body["organization_id"]
  end

  test "member cannot create a store" do
    assert_no_difference("Store.count") do
      post "/api/v1/stores",
        params: {
          store: {
            name: "Member Store",
            platform: "shopify",
            external_id: "shopify-acme-member-001",
            currency: "EUR",
            timezone: "Europe/Paris",
            status: "active"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner can update a store from their organization" do
    patch "/api/v1/stores/#{@acme_store.id}",
      params: {
        store: {
          name: "Updated Acme Store"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal "Updated Acme Store", body["name"]
  end

  test "member cannot update a store" do
    patch "/api/v1/stores/#{@acme_store.id}",
      params: {
        store: {
          name: "Unauthorized Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner cannot update a store from another organization" do
    patch "/api/v1/stores/#{@another_store.id}",
      params: {
        store: {
          name: "Unauthorized Cross Organization Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner can destroy a store from their organization" do
    assert_difference("Store.count", -1) do
      delete "/api/v1/stores/#{@acme_store.id}", headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }
    end

    assert_response :no_content
  end

  test "member cannot destroy a store" do
    assert_no_difference("Store.count") do
      delete "/api/v1/stores/#{@acme_store.id}", headers: {
        "Authorization" => "Bearer #{@member_token}"
      }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner cannot destroy a store from another organization" do
    assert_no_difference("Store.count") do
      delete "/api/v1/stores/#{@another_store.id}", headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "returns validation errors when creating an invalid store" do
    assert_no_difference("Store.count") do
      post "/api/v1/stores",
        params: {
          store: {
            name: "",
            platform: "shopify",
            external_id: "shopify-acme-invalid",
            currency: "EUR",
            timezone: "Europe/Paris",
            status: "active"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_includes body["errors"], "Name can't be blank"
  end

  test "returns validation errors when updating an invalid store" do
    patch "/api/v1/stores/#{@acme_store.id}",
      params: {
        store: {
          platform: "invalid"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_includes body["errors"], "Platform is not included in the list"
  end
end
