require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @acme_product = products(:acme_product)
    @another_product = products(:another_product)
    @acme_store = stores(:acme_store)
    @another_store = stores(:another_store)

    @owner_token = JwtService.encode(@owner)
    @member_token = JwtService.encode(@member)
  end

  test "lists only products from the current user's organization" do
    get "/api/v1/products", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |product| product["id"] }

    assert_includes ids, @acme_product.id
    refute_includes ids, @another_product.id
  end

  test "member can list only products from their organization" do
    get "/api/v1/products", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)
    ids = body.map { |product| product["id"] }

    assert_includes ids, @acme_product.id
    refute_includes ids, @another_product.id
  end

  test "shows a product from the current user's organization" do
    get "/api/v1/products/#{@acme_product.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal @acme_product.id, body["id"]
    assert_equal @acme_product.title, body["title"]
    assert_equal @acme_product.store_id, body["store_id"]
  end

  test "member can show a product from their organization" do
    get "/api/v1/products/#{@acme_product.id}", headers: {
      "Authorization" => "Bearer #{@member_token}"
    }

    assert_response :ok
  end

  test "forbids access to a product from another organization" do
    get "/api/v1/products/#{@another_product.id}", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "rejects unauthenticated index access" do
    get "/api/v1/products"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "rejects unauthenticated show access" do
    get "/api/v1/products/#{@acme_product.id}"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end

  test "owner can create a product in their organization" do
    assert_difference("Product.count", 1) do
      post "/api/v1/products",
        params: {
          product: {
            store_id: @acme_store.id,
            external_id: "product-acme-002",
            title: "New Product",
            description: "New product description",
            sku: "ACME-002",
            product_type: "physical",
            status: "active",
            price: 129.90,
            currency: "EUR"
          }
        },
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :created

    body = JSON.parse(response.body)

    assert_equal "New Product", body["title"]
    assert_equal @acme_store.id, body["store_id"]
    assert_equal "129.9", body["price"]
  end

  test "member cannot create a product" do
    assert_no_difference("Product.count") do
      post "/api/v1/products",
        params: {
          product: {
            store_id: @acme_store.id,
            external_id: "product-acme-member-001",
            title: "Member Product",
            status: "active",
            price: 49.90,
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

  test "owner cannot create a product in another organization store" do
    assert_no_difference("Product.count") do
      post "/api/v1/products",
        params: {
          product: {
            store_id: @another_store.id,
            external_id: "product-cross-org-001",
            title: "Cross Organization Product",
            status: "active",
            price: 99.90,
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

  test "owner can update a product from their organization" do
    patch "/api/v1/products/#{@acme_product.id}",
      params: {
        product: {
          title: "Updated Product",
          price: 199.90
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_product.reload

    assert_equal "Updated Product", @acme_product.title
    assert_equal BigDecimal("199.90"), @acme_product.price
  end

  test "member cannot update a product" do
    patch "/api/v1/products/#{@acme_product.id}",
      params: {
        product: {
          title: "Unauthorized Update"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@member_token}"
      }

    assert_response :forbidden

    @acme_product.reload

    assert_equal "Acme Product", @acme_product.title
  end

  test "store_id cannot be changed during product update" do
    original_store_id = @acme_product.store_id

    patch "/api/v1/products/#{@acme_product.id}",
      params: {
        product: {
          store_id: @another_store.id,
          title: "Attempted Move"
        }
      },
      headers: {
        "Authorization" => "Bearer #{@owner_token}"
      }

    assert_response :ok

    @acme_product.reload

    assert_equal original_store_id, @acme_product.store_id
    assert_equal "Attempted Move", @acme_product.title
  end

  test "owner cannot destroy a product with order items" do
    assert_no_difference("Product.count") do
      delete "/api/v1/products/#{@acme_product.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :conflict

    body = JSON.parse(response.body)

    assert_equal "Cannot delete record because of dependent order_items", body["error"]
    assert Product.exists?(@acme_product.id)
    assert OrderItem.exists?(order_items(:acme_order_item).id)
  end

  test "member cannot destroy a product" do
    assert_no_difference("Product.count") do
      delete "/api/v1/products/#{@acme_product.id}",
        headers: {
          "Authorization" => "Bearer #{@member_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "user cannot destroy a product from another organization" do
    assert_no_difference("Product.count") do
      delete "/api/v1/products/#{@another_product.id}",
        headers: {
          "Authorization" => "Bearer #{@owner_token}"
        }
    end

    assert_response :forbidden

    body = JSON.parse(response.body)

    assert_equal "Forbidden", body["error"]
  end

  test "create returns validation errors" do
    assert_no_difference("Product.count") do
      post "/api/v1/products",
        params: {
          product: {
            store_id: @acme_store.id,
            external_id: nil,
            title: nil,
            status: "invalid",
            price: -10,
            currency: nil
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
