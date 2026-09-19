require "test_helper"

class Api::V1::IntegrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_integration = integrations(:acme_shopify)
    @another_integration = integrations(:another_shopify)
    @acme_organization = organizations(:acme)
    @another_organization = organizations(:another)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only integrations from the current user's organization" do
    get "/api/v1/integrations", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |integration| integration["id"] }

    assert_includes ids, @acme_integration.id
    refute_includes ids, @another_integration.id
  end

  test "member can list only integrations from their organization" do
    get "/api/v1/integrations", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |integration| integration["id"] }

    assert_includes ids, @acme_integration.id
    refute_includes ids, @another_integration.id
  end

  test "does not expose credentials when listing integrations" do
    get "/api/v1/integrations", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    integration = body.find { |item| item["id"] == @acme_integration.id }

    refute_nil integration
    refute integration.key?("credentials")
  end

  test "shows an integration from the current user's organization" do
    get "/api/v1/integrations/#{@acme_integration.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_integration.id, body["id"]
    assert_equal @acme_integration.name, body["name"]
    assert_equal @acme_integration.provider, body["provider"]
    assert_equal @acme_integration.kind, body["kind"]
    assert_equal @acme_integration.organization_id, body["organization_id"]
  end

  test "does not expose credentials when showing an integration" do
    get "/api/v1/integrations/#{@acme_integration.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    refute body.key?("credentials")
  end

  test "member can show an integration from their organization" do
    get "/api/v1/integrations/#{@acme_integration.id}", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok
  end

  test "forbids access to an integration from another organization" do
    get "/api/v1/integrations/#{@another_integration.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/integrations"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/integrations/#{@acme_integration.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create an integration in their organization" do
    assert_difference("Integration.count", 1) do
      post "/api/v1/integrations",
        params: {
          integration: {
            organization_id: @acme_organization.id,
            store_id: @acme_integration.store_id,
            provider: "shopify",
            kind: "store",
            name: "New Shopify Integration",
            status: "active",
            external_id: "shopify-new-001",
            credentials: {
              access_token: "new-secret-token",
              shop_domain: "new.example.com"
            }
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New Shopify Integration", body["name"]
    assert_equal @acme_organization.id, body["organization_id"]
    assert_equal "shopify", body["provider"]
    assert_equal "store", body["kind"]
    assert_equal "active", body["status"]
    refute body.key?("credentials")

    integration = Integration.find_by!(name: "New Shopify Integration")

    assert_equal "new-secret-token",
      integration.attributes["credentials"]["access_token"]
  end

  test "member cannot create an integration" do
    assert_no_difference("Integration.count") do
      post "/api/v1/integrations",
        params: {
          integration: {
            organization_id: @acme_organization.id,
            store_id: @acme_integration.store_id,
            provider: "shopify",
            kind: "store",
            name: "Member Integration"
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

  test "owner cannot create an integration in another organization" do
    assert_no_difference("Integration.count") do
      post "/api/v1/integrations",
        params: {
          integration: {
            organization_id: @another_organization.id,
            store_id: @another_integration.store_id,
            provider: "shopify",
            kind: "store",
            name: "Cross Organization Integration"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner can update an integration from their organization" do
    patch "/api/v1/integrations/#{@acme_integration.id}",
      params: {
        integration: {
          name: "Updated Shopify Integration",
          status: "inactive"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_integration.reload

    assert_equal "Updated Shopify Integration", @acme_integration.name
    assert_equal "inactive", @acme_integration.status
  end

  test "update returns validation errors" do
    patch "/api/v1/integrations/#{@acme_integration.id}",
      params: {
        integration: {
          name: ""
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "Validation failed", body["error"]
    assert_kind_of Array, body["errors"]
    assert body["errors"].present?

    @acme_integration.reload

    assert_equal "Acme Shopify", @acme_integration.name
  end

  test "member cannot update an integration" do
    patch "/api/v1/integrations/#{@acme_integration.id}",
      params: {
        integration: {
          name: "Unauthorized Integration Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @acme_integration.reload

    assert_equal "Acme Shopify", @acme_integration.name
  end

  test "owner cannot update an integration from another organization" do
    patch "/api/v1/integrations/#{@another_integration.id}",
      params: {
        integration: {
          name: "Unauthorized Cross Organization Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    @another_integration.reload

    assert_equal "Another Shopify", @another_integration.name
  end

  test "organization_id cannot be changed during integration update" do
    original_organization_id = @acme_integration.organization_id

    patch "/api/v1/integrations/#{@acme_integration.id}",
      params: {
        integration: {
          organization_id: @another_organization.id,
          name: "Attempted Move"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_integration.reload

    assert_equal original_organization_id, @acme_integration.organization_id
    assert_equal "Attempted Move", @acme_integration.name
  end

  test "credentials can be updated without being returned" do
    patch "/api/v1/integrations/#{@acme_integration.id}",
      params: {
        integration: {
          credentials: {
            access_token: "updated-secret-token"
          }
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)

    refute body.key?("credentials")

    @acme_integration.reload

    assert_equal "updated-secret-token",
      @acme_integration.attributes["credentials"]["access_token"]
  end

  test "owner can destroy an integration from their organization" do
    assert_difference("Integration.count", -1) do
      delete "/api/v1/integrations/#{@acme_integration.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :no_content
    assert_empty response.body
    refute Integration.exists?(@acme_integration.id)
  end

  test "member cannot destroy an integration" do
    assert_no_difference("Integration.count") do
      delete "/api/v1/integrations/#{@acme_integration.id}",
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "user cannot destroy an integration from another organization" do
    assert_no_difference("Integration.count") do
      delete "/api/v1/integrations/#{@another_integration.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "create returns validation errors" do
    assert_no_difference("Integration.count") do
      post "/api/v1/integrations",
        params: {
          integration: {
            organization_id: @acme_organization.id,
            provider: "invalid",
            kind: "invalid",
            name: nil,
            status: "invalid"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_equal "Validation failed", body["error"]
    assert_kind_of Array, body["errors"]
    assert body["errors"].present?
  end

  test "returns not found when showing a non-existent integration" do
    get "/api/v1/integrations/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when updating a non-existent integration" do
    patch "/api/v1/integrations/#{SecureRandom.uuid}",
      params: {
        integration: {
          name: "Updated Integration"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when destroying a non-existent integration" do
    delete "/api/v1/integrations/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end
end
