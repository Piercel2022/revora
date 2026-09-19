require "test_helper"

class Api::V1::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)

    @order = orders(:acme_order)
    @another_order = orders(:another_order)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "index requires authentication" do
    get api_v1_orders_url

    assert_response :unauthorized
  end

  test "index returns orders from user's organization" do
    get api_v1_orders_url,
      headers: { "Authorization" => "Bearer #{@owner_token}" }

    assert_response :success

    response_orders = JSON.parse(response.body)

    assert_equal 1, response_orders.length
    assert_equal @order.id, response_orders.first["id"]
  end

  test "index does not return orders from another organization" do
    get api_v1_orders_url,
      headers: { "Authorization" => "Bearer #{@owner_token}" }

    assert_response :success

    response_orders = JSON.parse(response.body)

    returned_ids = response_orders.map { |order| order["id"] }

    assert_includes returned_ids, @order.id
    assert_not_includes returned_ids, @another_order.id
  end

  test "show returns order from user's organization" do
    get api_v1_order_url(@order),
      headers: { "Authorization" => "Bearer #{@owner_token}" }

    assert_response :success

    response_order = JSON.parse(response.body)

    assert_equal @order.id, response_order["id"]
  end

  test "show denies order from another organization" do
    get api_v1_order_url(@another_order),
      headers: { "Authorization" => "Bearer #{@owner_token}" }

    assert_response :forbidden
  end

  test "create requires management role" do
    assert_no_difference("Order.count") do
      post api_v1_orders_url,
        params: {
          order: {
            store_id: @order.store_id,
            customer_id: @order.customer_id,
            external_id: "order-member-001",
            order_number: "MEMBER-1001",
            status: "pending",
            currency: "EUR",
            subtotal: 100,
            tax: 20,
            shipping: 10,
            discount: 5,
            total: 125
          }
        },
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden
  end

  test "owner can create an order" do
    assert_difference("Order.count", 1) do
      post api_v1_orders_url,
        params: {
          order: {
            store_id: @order.store_id,
            customer_id: @order.customer_id,
            external_id: "order-created-001",
            order_number: "CREATED-1001",
            status: "pending",
            currency: "EUR",
            subtotal: 100,
            tax: 20,
            shipping: 10,
            discount: 5,
            total: 125
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    response_order = JSON.parse(response.body)

    assert_equal "order-created-001", response_order["external_id"]
    assert_equal "CREATED-1001", response_order["order_number"]
  end

  test "owner cannot create an order in another organization" do
    assert_no_difference("Order.count") do
      post api_v1_orders_url,
        params: {
          order: {
            store_id: @another_order.store_id,
            customer_id: @another_order.customer_id,
            external_id: "cross-org-order-001",
            order_number: "CROSS-ORG-1001",
            status: "pending",
            currency: "EUR",
            subtotal: 100,
            tax: 20,
            shipping: 10,
            discount: 5,
            total: 125
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden
  end

  test "owner can update an order" do
    patch api_v1_order_url(@order),
      params: {
        order: {
          status: "paid",
          total: 130
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :success

    @order.reload

    assert_equal "paid", @order.status
    assert_equal 130.to_d, @order.total
  end

  test "member cannot update an order" do
    patch api_v1_order_url(@order),
      params: {
        order: {
          status: "paid"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @order.reload

    assert_equal "pending", @order.status
  end

  test "owner cannot update an order from another organization" do
    patch api_v1_order_url(@another_order),
      params: {
        order: {
          status: "fulfilled"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :forbidden
  end

  test "update ignores store_id" do
    patch api_v1_order_url(@order),
      params: {
        order: {
          store_id: @another_order.store_id,
          status: "paid"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :success

    @order.reload

    assert_equal stores(:acme_store).id, @order.store_id
    assert_equal "paid", @order.status
  end

  test "create returns validation errors" do
    assert_no_difference("Order.count") do
      post api_v1_orders_url,
        params: {
          order: {
            store_id: @order.store_id,
            customer_id: @order.customer_id,
            external_id: nil,
            order_number: "INVALID-1001",
            status: "pending",
            currency: "EUR",
            subtotal: 100,
            tax: 20,
            shipping: 10,
            discount: 5,
            total: 125
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :unprocessable_entity

    response_body = JSON.parse(response.body)

    assert_equal "Validation failed", response_body["error"]
    assert_kind_of Array, response_body["errors"]
    assert response_body["errors"].present?
    assert_includes response_body["errors"], "External can't be blank"
  end

  test "owner can destroy an order" do
    order_id = @order.id

    assert_difference("Order.count", -1) do
      delete api_v1_order_url(@order),
        headers: { "Authorization" => "Bearer #{@owner_token}" }
    end

    assert_response :no_content
    assert_not Order.exists?(order_id)
  end

  test "member cannot destroy an order" do
    assert_no_difference("Order.count") do
      delete api_v1_order_url(@order),
        headers: { "Authorization" => "Bearer #{@member_token}" }
    end

    assert_response :forbidden
  end

  test "destroy denies order from another organization" do
    assert_no_difference("Order.count") do
      delete api_v1_order_url(@another_order),
        headers: { "Authorization" => "Bearer #{@owner_token}" }
    end

    assert_response :forbidden
  end
end
