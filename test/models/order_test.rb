require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
  @store = stores(:acme_store)
  @customer = customers(:acme_customer)

  @order = Order.new(
    store: @store,
    customer: @customer,
    external_id: "order-test-001",
    order_number: "TEST-1001",
    status: "pending",
    currency: "EUR",
    subtotal: 100.00,
    tax: 20.00,
    shipping: 10.00,
    discount: 5.00,
    total: 125.00,
    ordered_at: Time.current
  )
end

  test "is valid with valid attributes" do
    assert @order.valid?
  end

  test "requires a store" do
    @order.store = nil

    assert_not @order.valid?
    assert_includes @order.errors[:store], "must exist"
  end

  test "customer is optional" do
    @order.customer = nil

    assert @order.valid?
  end

  test "requires external_id" do
    @order.external_id = nil

    assert_not @order.valid?
    assert_includes @order.errors[:external_id], "can't be blank"
  end

  test "external_id must be unique within a store" do
    @order.save!

    duplicate = @order.dup

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "has already been taken"
  end

  test "same external_id is allowed in another store" do
    @order.save!

    other_store = stores(:another_store)

    other_order = Order.new(
      store: other_store,
      external_id: @order.external_id,
      order_number: "ANOTHER-TEST-1001",
      status: "pending",
      currency: "EUR",
      subtotal: 100.00,
      tax: 20.00,
      shipping: 0,
      discount: 0,
      total: 120.00
    )

    assert other_order.valid?
  end

  test "requires order_number" do
    @order.order_number = nil

    assert_not @order.valid?
    assert_includes @order.errors[:order_number], "can't be blank"
  end

  test "order_number must be unique within a store" do
    @order.save!

    duplicate = @order.dup

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:order_number], "has already been taken"
  end

  test "accepts valid statuses" do
    %w[pending paid fulfilled cancelled refunded].each do |status|
      @order.status = status

      assert @order.valid?, "Expected #{status} to be valid"
    end
  end

  test "rejects invalid status" do
    @order.status = "unknown"

    assert_not @order.valid?
    assert_includes @order.errors[:status], "is not included in the list"
  end

  test "requires currency" do
    @order.currency = nil

    assert_not @order.valid?
    assert_includes @order.errors[:currency], "can't be blank"
  end

  test "rejects negative monetary values" do
    %i[subtotal tax shipping discount total].each do |attribute|
      @order.public_send("#{attribute}=", -1)

      assert_not @order.valid?, "Expected #{attribute} to reject negative values"
      assert_includes @order.errors[attribute], "must be greater than or equal to 0"

      @order.public_send("#{attribute}=", 0)
    end
  end

  test "allows zero monetary values" do
    @order.subtotal = 0
    @order.tax = 0
    @order.shipping = 0
    @order.discount = 0
    @order.total = 0

    assert @order.valid?
  end

  test "rejects customer belonging to another store" do
    @order.customer = customers(:another_customer)

    assert_not @order.valid?
    assert_includes @order.errors[:customer], "must belong to the same store"
  end

  test "accepts customer belonging to the same store" do
    @order.customer = customers(:acme_customer)

    assert @order.valid?
  end
end
