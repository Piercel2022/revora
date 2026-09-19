require "test_helper"

class Api::V1::CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_customer = customers(:acme_customer)
    @another_customer = customers(:another_customer)
    @acme_store = stores(:acme_store)
    @another_store = stores(:another_store)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only customers from the current user's organization" do
    get "/api/v1/customers", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |customer| customer["id"] }

    assert_includes ids, @acme_customer.id
    refute_includes ids, @another_customer.id
  end

  test "shows a customer from the current user's organization" do
    get "/api/v1/customers/#{@acme_customer.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_customer.id, body["id"]
    assert_equal @acme_customer.first_name, body["first_name"]
    assert_equal @acme_customer.email, body["email"]
  end

  test "forbids access to a customer from another organization" do
    get "/api/v1/customers/#{@another_customer.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/customers"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/customers/#{@acme_customer.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create a customer in their organization" do
    assert_difference("Customer.count", 1) do
      post "/api/v1/customers",
        params: {
          customer: {
            store_id: @acme_store.id,
            external_id: "customer-acme-002",
            first_name: "New",
            last_name: "Customer",
            email: "new-customer@acme.test",
            phone: "+33123456789",
            company_name: "New Customer",
            status: "active"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New", body["first_name"]
    assert_equal @acme_store.id, body["store_id"]
  end

  test "member cannot create a customer" do
    assert_no_difference("Customer.count") do
      post "/api/v1/customers",
        params: {
          customer: {
            store_id: @acme_store.id,
            external_id: "customer-acme-member-001",
            first_name: "Member",
            last_name: "Customer",
            email: "member-customer@acme.test",
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

  test "owner cannot create a customer in another organization" do
    assert_no_difference("Customer.count") do
      post "/api/v1/customers",
        params: {
          customer: {
            store_id: @another_store.id,
            external_id: "customer-another-unauthorized",
            first_name: "Unauthorized",
            last_name: "Customer",
            email: "unauthorized@another.test",
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

  test "owner can update a customer from their organization" do
    patch "/api/v1/customers/#{@acme_customer.id}",
      params: {
        customer: {
          first_name: "Updated"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal "Updated", body["first_name"]
  end

  test "member cannot update a customer" do
    patch "/api/v1/customers/#{@acme_customer.id}",
      params: {
        customer: {
          first_name: "Unauthorized"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner cannot update a customer from another organization" do
    patch "/api/v1/customers/#{@another_customer.id}",
      params: {
        customer: {
          first_name: "Unauthorized Cross Organization Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "cannot move a customer to another organization's store" do
    original_store_id = @acme_customer.store_id

    patch "/api/v1/customers/#{@acme_customer.id}",
      params: {
        customer: {
          store_id: @another_store.id
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal original_store_id, body["store_id"]
    assert_equal original_store_id, @acme_customer.reload.store_id
  end

  test "owner can destroy a customer from their organization" do
    assert_difference("Customer.count", -1) do
      delete "/api/v1/customers/#{@acme_customer.id}", headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }
    end

    assert_response :no_content
  end

  test "member cannot destroy a customer" do
    assert_no_difference("Customer.count") do
      delete "/api/v1/customers/#{@acme_customer.id}", headers: {
        "Authorization" => "Bearer #{@member_token}"
      }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "owner cannot destroy a customer from another organization" do
    assert_no_difference("Customer.count") do
      delete "/api/v1/customers/#{@another_customer.id}", headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "returns validation errors when creating an invalid customer" do
    assert_no_difference("Customer.count") do
      post "/api/v1/customers",
        params: {
          customer: {
            store_id: @acme_store.id,
            first_name: "Invalid",
            email: "not-an-email",
            status: "active"
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

  test "returns validation errors when updating an invalid customer" do
    patch "/api/v1/customers/#{@acme_customer.id}",
      params: {
        customer: {
          email: "invalid-email"
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
  end
end
