require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "accepts a valid order item" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      external_id: "line-acme-002",
      title: "Acme Product",
      sku: "ACME-001",
      quantity: 2,
      unit_price: 50.00,
      discount: 5.00,
      tax: 19.00,
      total: 114.00,
      currency: "EUR"
    )

    assert_predicate order_item, :valid?
  end

  test "requires an order" do
    order_item = OrderItem.new(
      product: products(:acme_product),
      title: "Acme Product"
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:order], "must exist"
  end

  test "requires a product" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      title: "Acme Product"
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:product], "must exist"
  end

  test "requires a title" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      title: nil
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:title], "can't be blank"
  end

  test "requires a positive integer quantity" do
    [0, -1].each do |quantity|
      order_item = OrderItem.new(
        order: orders(:acme_order),
        product: products(:acme_product),
        title: "Acme Product",
        quantity: quantity
      )

      assert_not order_item.valid?
      assert order_item.errors[:quantity].any?
    end
  end

  test "requires quantity to be an integer" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      title: "Acme Product",
      quantity: 1.5
    )

    assert_not order_item.valid?
    assert order_item.errors[:quantity].any?
  end

  test "rejects negative monetary values" do
    %i[unit_price discount tax total].each do |attribute|
      order_item = OrderItem.new(
        order: orders(:acme_order),
        product: products(:acme_product),
        title: "Acme Product",
        attribute => -1
      )

      assert_not order_item.valid?
      assert order_item.errors[attribute].any?
    end
  end

  test "requires currency" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      title: "Acme Product",
      currency: nil
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:currency], "can't be blank"
  end

  test "allows a blank external id" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      title: "Acme Product",
      external_id: nil
    )

    assert_predicate order_item, :valid?
  end

  test "requires external id to be unique within an order" do
    existing_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      external_id: "line-acme-unique",
      title: "Existing Product"
    )
    assert_predicate existing_item, :valid?
    existing_item.save!

    duplicate_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      external_id: "line-acme-unique",
      title: "Duplicate Product"
    )

    assert_not duplicate_item.valid?
    assert duplicate_item.errors[:external_id].any?
  end

  test "allows the same external id on different orders" do
    first_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:acme_product),
      external_id: "line-shared",
      title: "First Product"
    )
    assert_predicate first_item, :valid?
    first_item.save!

    second_item = OrderItem.new(
      order: orders(:another_order),
      product: products(:another_product),
      external_id: "line-shared",
      title: "Second Product"
    )

    assert_predicate second_item, :valid?
  end

  test "rejects a product from another store" do
    order_item = OrderItem.new(
      order: orders(:acme_order),
      product: products(:another_product),
      title: "Wrong Store Product"
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:product], "must belong to the same store"
  end

  test "destroying an order destroys its order items" do
    order = orders(:acme_order)
    order_item = order_items(:acme_order_item)

    assert_difference("OrderItem.count", -1) do
      order.destroy
    end

    assert_not OrderItem.exists?(order_item.id)
  end

  test "destroying a product with order items raises an exception" do
    product = products(:acme_product)

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      product.destroy
    end

    assert Product.exists?(product.id)
    assert OrderItem.exists?(order_items(:acme_order_item).id)
  end
end
