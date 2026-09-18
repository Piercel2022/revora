require "test_helper"

class OrderItemPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @order_item = order_items(:acme_order_item)
    @another_order_item = order_items(:another_order_item)
  end

  test "owner can access order items in their organization" do
    policy = OrderItemPolicy.new(@owner, @order_item)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "member can index order items" do
    policy = OrderItemPolicy.new(@member, @order_item)

    assert policy.index?
  end

  test "member can view order items in their organization" do
    policy = OrderItemPolicy.new(@member, @order_item)

    assert policy.show?
  end

  test "member cannot create order items" do
    policy = OrderItemPolicy.new(@member, @order_item)

    assert_not policy.create?
  end

  test "member cannot update order items" do
    policy = OrderItemPolicy.new(@member, @order_item)

    assert_not policy.update?
  end

  test "member cannot destroy order items" do
    policy = OrderItemPolicy.new(@member, @order_item)

    assert_not policy.destroy?
  end

  test "owner cannot access order items from another organization" do
    policy = OrderItemPolicy.new(@owner, @another_order_item)

    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "scope returns only order items from user's organization" do
    scope = OrderItemPolicy::Scope.new(@owner, OrderItem).resolve

    assert_includes scope, @order_item
    assert_not_includes scope, @another_order_item
  end

  test "member scope returns only order items from their organization" do
    scope = OrderItemPolicy::Scope.new(@member, OrderItem).resolve

    assert_includes scope, @order_item
    assert_not_includes scope, @another_order_item
  end
end
