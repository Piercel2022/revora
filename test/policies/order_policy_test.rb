require "test_helper"

class OrderPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @order = orders(:acme_order)
    @another_order = orders(:another_order)
  end

  test "owner can access orders in their organization" do
    policy = OrderPolicy.new(@owner, @order)

    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "member can index orders" do
    policy = OrderPolicy.new(@member, @order)

    assert policy.index?
  end

  test "member can view orders in their organization" do
    policy = OrderPolicy.new(@member, @order)

    assert policy.show?
  end

  test "member cannot create orders" do
    policy = OrderPolicy.new(@member, @order)

    assert_not policy.create?
  end

  test "member cannot update orders" do
    policy = OrderPolicy.new(@member, @order)

    assert_not policy.update?
  end

  test "member cannot destroy orders" do
    policy = OrderPolicy.new(@member, @order)

    assert_not policy.destroy?
  end

  test "owner cannot access orders from another organization" do
    policy = OrderPolicy.new(@owner, @another_order)

    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "scope returns only orders from user's organization" do
    scope = OrderPolicy::Scope.new(@owner, Order).resolve

    assert_includes scope, @order
    assert_not_includes scope, @another_order
  end

  test "member scope returns only orders from their organization" do
    scope = OrderPolicy::Scope.new(@member, Order).resolve

    assert_includes scope, @order
    assert_not_includes scope, @another_order
  end
end
