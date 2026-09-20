require "test_helper"

class Api::V1::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @owner_token = JwtService.encode(@owner)

    @acme_store = stores(:acme_store)
    @another_store = stores(:another_store)

    @acme_customer = customers(:acme_customer)
    @another_customer = customers(:another_customer)

    @acme_product = products(:acme_product)
    @another_product = products(:another_product)

    @acme_order = orders(:acme_order)
    @another_order = orders(:another_order)

    @acme_opportunity = opportunities(:acme_opportunity)
    @another_opportunity = opportunities(:another_opportunity)

    @acme_integration = integrations(:acme_shopify)
    @another_integration = integrations(:another_shopify)
  end

  test "returns the dashboard for the current organization" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal(
      %w[kpis stores orders opportunities integrations].sort,
      body.keys.sort
    )
  end

  test "returns organization scoped kpis" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal 125.0, body["kpis"]["revenue"]
    assert_equal 1, body["kpis"]["orders"]
    assert_equal 1, body["kpis"]["customers"]
    assert_equal 1, body["kpis"]["products"]
    assert_equal 1, body["kpis"]["stores"]
    assert_equal 1, body["kpis"]["open_opportunities"]
    assert_equal 15_000.0, body["kpis"]["pipeline_value"]
  end

  test "returns organization scoped store breakdown" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    stores = JSON.parse(response.body)["stores"]

    assert_equal 1, stores["total"]
    assert_equal 1, stores["active"]
    assert_equal 0, stores["paused"]
    assert_equal 0, stores["disconnected"]
  end

  test "returns organization scoped order breakdown" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    orders = JSON.parse(response.body)["orders"]

    assert_equal 1, orders["total"]
    assert_equal 1, orders["pending"]
    assert_equal 0, orders["paid"]
    assert_equal 0, orders["fulfilled"]
    assert_equal 0, orders["cancelled"]
    assert_equal 0, orders["refunded"]
  end

  test "returns organization scoped opportunity breakdown" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    opportunities = JSON.parse(response.body)["opportunities"]

    assert_equal 1, opportunities["total"]
    assert_equal 1, opportunities["open"]
    assert_equal 0, opportunities["won"]
    assert_equal 0, opportunities["lost"]
    assert_equal 15_000.0, opportunities["pipeline_value"]
    assert_equal 0.0, opportunities["won_value"]
  end

  test "returns organization scoped integration breakdown" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    integrations = JSON.parse(response.body)["integrations"]

    assert_equal 1, integrations["total"]
    assert_equal 1, integrations["active"]
    assert_equal 0, integrations["inactive"]
    assert_equal 0, integrations["error"]
  end

  test "isolates all dashboard data from another organization" do
    get "/api/v1/dashboard", headers: {
      "Authorization" => "Bearer #{@owner_token}"
    }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal 1, body["kpis"]["orders"]
    assert_equal 125.0, body["kpis"]["revenue"]
    assert_equal 1, body["kpis"]["customers"]
    assert_equal 1, body["kpis"]["products"]
    assert_equal 1, body["kpis"]["stores"]

    assert_equal 1, body["stores"]["total"]

    assert_equal 1, body["orders"]["total"]
    assert_equal 1, body["orders"]["pending"]
    assert_equal 0, body["orders"]["paid"]

    assert_equal 1, body["opportunities"]["total"]
    assert_equal 1, body["opportunities"]["open"]
    assert_equal 0, body["opportunities"]["won"]
    assert_equal 15_000.0, body["opportunities"]["pipeline_value"]

    assert_equal 1, body["integrations"]["total"]
    assert_equal 1, body["integrations"]["active"]

    refute_equal @another_store.id, @acme_store.id
    refute_equal @another_customer.id, @acme_customer.id
    refute_equal @another_product.id, @acme_product.id
    refute_equal @another_order.id, @acme_order.id
    refute_equal @another_opportunity.id, @acme_opportunity.id
    refute_equal @another_integration.id, @acme_integration.id
  end

  test "rejects unauthenticated access" do
    get "/api/v1/dashboard"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_equal "Missing authorization token", body["error"]
  end
end
