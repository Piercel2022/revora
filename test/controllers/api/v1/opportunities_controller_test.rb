require "test_helper"

class Api::V1::OpportunitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_opportunity = opportunities(:acme_opportunity)
    @another_opportunity = opportunities(:another_opportunity)
    @acme_organization = organizations(:acme)
    @another_organization = organizations(:another)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only opportunities from the current user's organization" do
    get "/api/v1/opportunities", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |opportunity| opportunity["id"] }

    assert_includes ids, @acme_opportunity.id
    refute_includes ids, @another_opportunity.id
  end

  test "member can list only opportunities from their organization" do
    get "/api/v1/opportunities", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |opportunity| opportunity["id"] }

    assert_includes ids, @acme_opportunity.id
    refute_includes ids, @another_opportunity.id
  end

  test "shows an opportunity from the current user's organization" do
    get "/api/v1/opportunities/#{@acme_opportunity.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_opportunity.id, body["id"]
    assert_equal @acme_opportunity.name, body["name"]
    assert_equal @acme_opportunity.organization_id, body["organization_id"]
  end

  test "member can show an opportunity from their organization" do
    get "/api/v1/opportunities/#{@acme_opportunity.id}", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok
  end

  test "forbids access to an opportunity from another organization" do
    get "/api/v1/opportunities/#{@another_opportunity.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/opportunities"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/opportunities/#{@acme_opportunity.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create an opportunity in their organization" do
    assert_difference("Opportunity.count", 1) do
      post "/api/v1/opportunities",
        params: {
          opportunity: {
            organization_id: @acme_organization.id,
            name: "New Opportunity",
            status: "open",
            value: "12500.00",
            expected_close_at: "2026-12-15 10:00:00"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New Opportunity", body["name"]
    assert_equal @acme_organization.id, body["organization_id"]
    assert_equal "open", body["status"]
    assert_equal "12500.0", body["value"]
  end

  test "member cannot create an opportunity" do
    assert_no_difference("Opportunity.count") do
      post "/api/v1/opportunities",
        params: {
          opportunity: {
            organization_id: @acme_organization.id,
            name: "Member Opportunity",
            status: "open",
            value: "5000.00"
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

  test "owner cannot create an opportunity in another organization" do
    assert_no_difference("Opportunity.count") do
      post "/api/v1/opportunities",
        params: {
          opportunity: {
            organization_id: @another_organization.id,
            name: "Cross Organization Opportunity",
            status: "open",
            value: "7500.00"
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

  test "owner can update an opportunity from their organization" do
    patch "/api/v1/opportunities/#{@acme_opportunity.id}",
      params: {
        opportunity: {
          name: "Updated Opportunity",
          status: "won",
          value: "18000.00"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_opportunity.reload

    assert_equal "Updated Opportunity", @acme_opportunity.name
    assert_equal "won", @acme_opportunity.status
    assert_equal 18_000.to_d, @acme_opportunity.value
  end

  test "member cannot update an opportunity" do
    patch "/api/v1/opportunities/#{@acme_opportunity.id}",
      params: {
        opportunity: {
          name: "Unauthorized Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @acme_opportunity.reload

    assert_equal "Acme VIP Expansion", @acme_opportunity.name
  end

  test "owner cannot update an opportunity from another organization" do
    patch "/api/v1/opportunities/#{@another_opportunity.id}",
      params: {
        opportunity: {
          name: "Unauthorized Cross Organization Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    @another_opportunity.reload

    assert_equal "Another Store Expansion", @another_opportunity.name
  end

  test "organization_id cannot be changed during opportunity update" do
    original_organization_id = @acme_opportunity.organization_id

    patch "/api/v1/opportunities/#{@acme_opportunity.id}",
      params: {
        opportunity: {
          organization_id: @another_organization.id,
          name: "Attempted Move"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_opportunity.reload

    assert_equal original_organization_id, @acme_opportunity.organization_id
    assert_equal "Attempted Move", @acme_opportunity.name
  end

  test "owner can destroy an opportunity from their organization" do
    assert_difference("Opportunity.count", -1) do
      delete "/api/v1/opportunities/#{@acme_opportunity.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :no_content
    refute Opportunity.exists?(@acme_opportunity.id)
  end

  test "member cannot destroy an opportunity" do
    assert_no_difference("Opportunity.count") do
      delete "/api/v1/opportunities/#{@acme_opportunity.id}",
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "user cannot destroy an opportunity from another organization" do
    assert_no_difference("Opportunity.count") do
      delete "/api/v1/opportunities/#{@another_opportunity.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "create returns validation errors" do
    assert_no_difference("Opportunity.count") do
      post "/api/v1/opportunities",
        params: {
          opportunity: {
            organization_id: @acme_organization.id,
            name: nil,
            status: "invalid",
            value: "-100"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert body["errors"].any?
  end

  test "returns not found when showing a non-existent opportunity" do
    get "/api/v1/opportunities/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when updating a non-existent opportunity" do
    patch "/api/v1/opportunities/#{SecureRandom.uuid}",
      params: {
        opportunity: {
          name: "Updated Opportunity"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when destroying a non-existent opportunity" do
    delete "/api/v1/opportunities/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end
end
