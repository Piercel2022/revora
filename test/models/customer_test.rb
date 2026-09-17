require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(
      name: "Test Organization",
      slug: "test-organization",
      status: "active"
    )

    @store = Store.create!(
      organization: @organization,
      name: "Test Store",
      platform: "shopify",
      external_id: "store-1",
      currency: "EUR",
      timezone: "Europe/Paris",
      status: "active"
    )
  end

  test "belongs to a store" do
    customer = Customer.new(store: @store)

    assert_respond_to customer, :store
    assert_equal @store, customer.store
  end

  test "accepts a valid customer" do
    customer = Customer.new(
      store: @store,
      first_name: "Jean",
      last_name: "Dupont",
      email: "jean@example.com",
      status: "active"
    )

    assert customer.valid?
  end

  test "rejects an invalid email" do
    customer = Customer.new(
      store: @store,
      email: "invalid-email"
    )

    assert_not customer.valid?
    assert_includes customer.errors[:email], "is invalid"
  end

  test "rejects an invalid status" do
    customer = Customer.new(
      store: @store,
      status: "unknown"
    )

    assert_not customer.valid?
    assert_includes customer.errors[:status], "is not included in the list"
  end

  test "allows a blank status" do
    customer = Customer.new(
      store: @store,
      status: nil
    )

    assert customer.valid?
  end

  test "allows a blank email" do
    customer = Customer.new(
      store: @store,
      email: nil
    )

    assert customer.valid?
  end
end