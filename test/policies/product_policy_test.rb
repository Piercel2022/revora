require "test_helper"

class ProductPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @product = products(:acme_product)
    @another_product = products(:another_product)
  end

  test "owner can index products" do
    assert ProductPolicy.new(@owner, @product).index?
  end

  test "member can index products" do
    assert ProductPolicy.new(@member, @product).index?
  end

  test "owner can show product from own organization" do
    assert ProductPolicy.new(@owner, @product).show?
  end

  test "member can show product from own organization" do
    assert ProductPolicy.new(@member, @product).show?
  end

  test "user cannot show product from another organization" do
    assert_not ProductPolicy.new(@owner, @another_product).show?
  end

  test "owner can create product in own organization" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "policy-product-001",
      title: "Policy Product",
      status: "active",
      currency: "EUR"
    )

    assert ProductPolicy.new(@owner, product).create?
  end

  test "member cannot create product" do
    product = Product.new(
      store: stores(:acme_store),
      external_id: "policy-product-002",
      title: "Policy Product",
      status: "active",
      currency: "EUR"
    )

    assert_not ProductPolicy.new(@member, product).create?
  end

  test "owner can update product from own organization" do
    assert ProductPolicy.new(@owner, @product).update?
  end

  test "member cannot update product" do
    assert_not ProductPolicy.new(@member, @product).update?
  end

  test "owner can destroy product from own organization" do
    assert ProductPolicy.new(@owner, @product).destroy?
  end

  test "member cannot destroy product" do
    assert_not ProductPolicy.new(@member, @product).destroy?
  end

  test "owner cannot destroy product from another organization" do
    assert_not ProductPolicy.new(@owner, @another_product).destroy?
  end

  test "scope only returns products from user's organization" do
    products = ProductPolicy::Scope.new(@owner, Product.all).resolve

    assert_includes products, @product
    assert_not_includes products, @another_product
  end
end
