require "test_helper"

class Api::V1::OrderItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)

    @acme_order = orders(:acme_order)
    @another_order = orders(:another_order)

    @acme_order_item = order_items(:acme_order_item)
    @another_order_item = order_items(:another_order_item)

    @acme_product = products(:acme_product)
    @another_product = products(:another_product)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists order items from the requested order" do
    get "/api/v1/orders/#{@acme_order.id}/order_items",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |order_item| order_item["id"] }

    assert_includes ids, @acme_order_item.id
    refute_includes ids, @another_order_item.id
  end

  test "member can list order items from their organization" do
    get "/api/v1/orders/#{@acme_order.id}/order_items",
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |order_item| order_item["id"] }

    assert_includes ids, @acme_order_item.id
    refute_includes ids, @another_order_item.id
  end

  test "forbids listing order items from another organization" do
    get "/api/v1/orders/#{@another_order.id}/order_items",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "shows an order item from the requested order" do
    get "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_order_item.id, body["id"]
    assert_equal @acme_order.id, body["order_id"]
    assert_equal @acme_product.id, body["product_id"]
  end

  test "member can show an order item from their organization" do
    get "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :ok
  end

  test "forbids showing an order item from another organization" do
    get "/api/v1/orders/#{@another_order.id}/order_items/#{@another_order_item.id}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "does not expose an order item through a different order" do
    get "/api/v1/orders/#{@acme_order.id}/order_items/#{@another_order_item.id}",
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :not_found
  end

  test "owner can create an order item in their order" do
    assert_difference("OrderItem.count", 1) do
      post "/api/v1/orders/#{@acme_order.id}/order_items",
        params: {
          order_item: {
            product_id: @acme_product.id,
            external_id: "line-acme-002",
            title: "Acme Product",
            sku: "ACME-001",
            quantity: 3,
            unit_price: 50.00,
            discount: 0,
            tax: 30.00,
            total: 180.00,
            currency: "EUR"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal @acme_order.id, body["order_id"]
    assert_equal @acme_product.id, body["product_id"]
    assert_equal 3, body["quantity"]
  end

  test "member cannot create an order item" do
    assert_no_difference("OrderItem.count") do
      post "/api/v1/orders/#{@acme_order.id}/order_items",
        params: {
          order_item: {
            product_id: @acme_product.id,
            external_id: "line-acme-member-001",
            title: "Unauthorized Item",
            quantity: 1,
            unit_price: 50.00,
            discount: 0,
            tax: 10.00,
            total: 60.00,
            currency: "EUR"
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

  test "owner cannot create an order item in another organization order" do
    assert_no_difference("OrderItem.count") do
      post "/api/v1/orders/#{@another_order.id}/order_items",
        params: {
          order_item: {
            product_id: @another_product.id,
            external_id: "line-cross-org-001",
            title: "Cross Organization Item",
            quantity: 1,
            unit_price: 80.00,
            discount: 0,
            tax: 16.00,
            total: 96.00,
            currency: "EUR"
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

  test "owner cannot add a product from another store to an order" do
    assert_no_difference("OrderItem.count") do
      post "/api/v1/orders/#{@acme_order.id}/order_items",
        params: {
          order_item: {
            product_id: @another_product.id,
            external_id: "line-wrong-store-001",
            title: "Wrong Store Product",
            quantity: 1,
            unit_price: 80.00,
            discount: 0,
            tax: 16.00,
            total: 96.00,
            currency: "EUR"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)

    assert_includes body["errors"], "Product must belong to the same store"
  end

  test "owner can update an order item from their order" do
    patch "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      params: {
        order_item: {
          quantity: 4,
          unit_price: 55.00
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_order_item.reload

    assert_equal 4, @acme_order_item.quantity
    assert_equal BigDecimal("55.00"), @acme_order_item.unit_price
  end

  test "member cannot update an order item" do
    patch "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      params: {
        order_item: {
          quantity: 10
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @acme_order_item.reload

    assert_equal 2, @acme_order_item.quantity
  end

  test "order_id cannot be changed during order item update" do
    original_order_id = @acme_order_item.order_id

    patch "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      params: {
        order_item: {
          order_id: @another_order.id,
          quantity: 4
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_order_item.reload

    assert_equal original_order_id, @acme_order_item.order_id
    assert_equal 4, @acme_order_item.quantity
  end

  test "product_id cannot be changed to a product from another store" do
    original_product_id = @acme_order_item.product_id

    patch "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
      params: {
        order_item: {
          product_id: @another_product.id
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :unprocessable_entity

    @acme_order_item.reload

    assert_equal original_product_id, @acme_order_item.product_id
  end

  test "owner can destroy an order item from their order" do
    assert_difference("OrderItem.count", -1) do
      delete "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :no_content
  end

  test "member cannot destroy an order item" do
    assert_no_difference("OrderItem.count") do
      delete "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}",
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "user cannot destroy an order item from another organization" do
    assert_no_difference("OrderItem.count") do
      delete "/api/v1/orders/#{@another_order.id}/order_items/#{@another_order_item.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/orders/#{@acme_order.id}/order_items"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/orders/#{@acme_order.id}/order_items/#{@acme_order_item.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated create access" do
    assert_no_difference("OrderItem.count") do
      post "/api/v1/orders/#{@acme_order.id}/order_items",
        params: {
          order_item: {
            product_id: @acme_product.id,
            external_id: "line-unauth-001",
            title: "Unauthorized Item",
            quantity: 1,
            unit_price: 50.00,
            discount: 0,
            tax: 10.00,
            total: 60.00,
            currency: "EUR"
          }
        }
    end

    assert_response :unauthorized
  end

  test "create returns validation errors" do
    assert_no_difference("OrderItem.count") do
      post "/api/v1/orders/#{@acme_order.id}/order_items",
        params: {
          order_item: {
            product_id: @acme_product.id,
            external_id: nil,
            title: nil,
            quantity: 0,
            unit_price: -10,
            discount: 0,
            tax: 0,
            total: 0,
            currency: "EUR"
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
end
