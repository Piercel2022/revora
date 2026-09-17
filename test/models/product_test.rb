require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "valid product" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-001",
      title: "Test Product",
      description: "A test product",
      sku: "TEST-001",
      product_type: "physical",
      status: "active",
      price: 49.90,
      currency: "EUR"
    )

    assert product.valid?
  end

  test "requires a store" do
    product = Product.new(
      external_id: "product-test-002",
      title: "Test Product",
      status: "active",
      currency: "EUR"
    )

    assert_not product.valid?
    assert_includes product.errors[:store], "must exist"
  end

  test "requires external_id" do
    product = Product.new(
      store: stores(:acme_store),
      title: "Test Product",
      status: "active",
      currency: "EUR"
    )

    assert_not product.valid?
    assert_includes product.errors[:external_id], "can't be blank"
  end

  test "requires title" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-003",
      status: "active",
      currency: "EUR"
    )

    assert_not product.valid?
    assert_includes product.errors[:title], "can't be blank"
  end

  test "accepts valid statuses" do
    %w[active archived draft].each do |status|
      product = Product.new(
        store: stores(:acme_store),
        external_id: "product-#{status}",
        title: "Test Product",
        status: status,
        currency: "EUR"
      )

      assert product.valid?, "Expected #{status} to be valid"
    end
  end

  test "rejects invalid status" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-004",
      title: "Test Product",
      status: "deleted",
      currency: "EUR"
    )

    assert_not product.valid?
    assert_includes product.errors[:status], "is not included in the list"
  end

  test "rejects negative price" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-005",
      title: "Test Product",
      status: "active",
      price: -10,
      currency: "EUR"
    )

    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than or equal to 0"
  end

  test "allows nil price" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-006",
      title: "Test Product",
      status: "active",
      price: nil,
      currency: "EUR"
    )

    assert product.valid?
  end

  test "requires currency" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "product-test-007",
      title: "Test Product",
      status: "active",
      currency: nil
    )

    assert_not product.valid?
    assert_includes product.errors[:currency], "can't be blank"
  end

  test "external_id must be unique within the store" do
    existing_product = products(:acme_product)

    duplicate = Product.new(
      store: existing_product.store,
      external_id: existing_product.external_id,
      title: "Another Product",
      status: "active",
      currency: "EUR"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "has already been taken"
  end

  test "same external_id is allowed in another store" do
    existing_product = products(:acme_product)

    product = Product.new(
      store: stores(:another_store),
      external_id: existing_product.external_id,
      title: "Another Store Product",
      status: "active",
      currency: "EUR"
    )

    assert product.valid?
  end
end
