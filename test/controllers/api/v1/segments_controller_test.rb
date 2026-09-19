require "test_helper"

class Api::V1::SegmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_segment = segments(:acme_segment)
    @another_segment = segments(:another_segment)
    @acme_organization = organizations(:acme)
    @another_organization = organizations(:another)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only segments from the current user's organization" do
    get "/api/v1/segments", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |segment| segment["id"] }

    assert_includes ids, @acme_segment.id
    refute_includes ids, @another_segment.id
  end

  test "member can list only segments from their organization" do
    get "/api/v1/segments", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |segment| segment["id"] }

    assert_includes ids, @acme_segment.id
    refute_includes ids, @another_segment.id
  end

  test "shows a segment from the current user's organization" do
    get "/api/v1/segments/#{@acme_segment.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_segment.id, body["id"]
    assert_equal @acme_segment.name, body["name"]
    assert_equal @acme_segment.organization_id, body["organization_id"]
  end

  test "member can show a segment from their organization" do
    get "/api/v1/segments/#{@acme_segment.id}", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok
  end

  test "forbids access to a segment from another organization" do
    get "/api/v1/segments/#{@another_segment.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/segments"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/segments/#{@acme_segment.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create a segment in their organization" do
    assert_difference("Segment.count", 1) do
      post "/api/v1/segments",
        params: {
          segment: {
            organization_id: @acme_organization.id,
            name: "New Segment",
            description: "New segment description",
            status: "active"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New Segment", body["name"]
    assert_equal @acme_organization.id, body["organization_id"]
    assert_equal "active", body["status"]
  end

  test "member cannot create a segment" do
    assert_no_difference("Segment.count") do
      post "/api/v1/segments",
        params: {
          segment: {
            organization_id: @acme_organization.id,
            name: "Member Segment",
            description: "Unauthorized segment",
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

  test "owner cannot create a segment in another organization" do
    assert_no_difference("Segment.count") do
      post "/api/v1/segments",
        params: {
          segment: {
            organization_id: @another_organization.id,
            name: "Cross Organization Segment",
            description: "Unauthorized cross-organization segment",
            status: "active"
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

  test "owner can update a segment from their organization" do
    patch "/api/v1/segments/#{@acme_segment.id}",
      params: {
        segment: {
          name: "Updated Segment",
          description: "Updated description"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_segment.reload

    assert_equal "Updated Segment", @acme_segment.name
    assert_equal "Updated description", @acme_segment.description
  end

  test "member cannot update a segment" do
    patch "/api/v1/segments/#{@acme_segment.id}",
      params: {
        segment: {
          name: "Unauthorized Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @acme_segment.reload

    assert_equal "VIP Customers", @acme_segment.name
  end

  test "organization_id cannot be changed during segment update" do
    original_organization_id = @acme_segment.organization_id

    patch "/api/v1/segments/#{@acme_segment.id}",
      params: {
        segment: {
          organization_id: @another_organization.id,
          name: "Attempted Move"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_segment.reload

    assert_equal original_organization_id, @acme_segment.organization_id
    assert_equal "Attempted Move", @acme_segment.name
  end

  test "owner can destroy a segment from their organization" do
    assert_difference("Segment.count", -1) do
      delete "/api/v1/segments/#{@acme_segment.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :no_content
    refute Segment.exists?(@acme_segment.id)
  end

  test "member cannot destroy a segment" do
    assert_no_difference("Segment.count") do
      delete "/api/v1/segments/#{@acme_segment.id}",
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "user cannot destroy a segment from another organization" do
    assert_no_difference("Segment.count") do
      delete "/api/v1/segments/#{@another_segment.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "create returns validation errors" do
    assert_no_difference("Segment.count") do
      post "/api/v1/segments",
        params: {
          segment: {
            organization_id: @acme_organization.id,
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

  test "returns not found when showing a non-existent segment" do
    get "/api/v1/segments/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when updating a non-existent segment" do
    patch "/api/v1/segments/#{SecureRandom.uuid}",
      params: {
        segment: {
          name: "Updated Segment"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end

  test "returns not found when destroying a non-existent segment" do
    delete "/api/v1/segments/#{SecureRandom.uuid}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_equal "Not Found", body["error"]
  end
end
