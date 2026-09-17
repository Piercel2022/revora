require "test_helper"

class CustomerPolicyTest < ActiveSupport::TestCase
  setup do
    @acme = organizations(:acme)
    @another = organizations(:another)

    @owner = users(:owner)
    @member = users(:member)

    @another_owner = User.create!(
      organization: @another,
      email: "owner@another-customer.test",
      password: "password123",
      first_name: "Another",
      last_name: "Owner",
      role: "owner",
      active: true
    )

    @acme_customer = customers(:acme_customer)
    @another_customer = customers(:another_customer)
  end

  test "owner can index customers" do
    policy = CustomerPolicy.new(@owner, Customer)

    assert policy.index?
  end

  test "member can index customers" do
    policy = CustomerPolicy.new(@member, Customer)

    assert policy.index?
  end

  test "owner can show customer in their organization" do
    policy = CustomerPolicy.new(@owner, @acme_customer)

    assert policy.show?
  end

  test "member can show customer in their organization" do
    policy = CustomerPolicy.new(@member, @acme_customer)

    assert policy.show?
  end

  test "user cannot show customer from another organization" do
    policy = CustomerPolicy.new(@owner, @another_customer)

    refute policy.show?
  end

  test "owner can create customer in their organization" do
    customer = @acme_customer.store.customers.new

    policy = CustomerPolicy.new(@owner, customer)

    assert policy.create?
  end

  test "admin can create customer in their organization" do
    admin = User.create!(
      organization: @acme,
      email: "admin@acme-customer.test",
      password: "password123",
      first_name: "Admin",
      last_name: "Acme",
      role: "admin",
      active: true
    )

    customer = @acme_customer.store.customers.new

    policy = CustomerPolicy.new(admin, customer)

    assert policy.create?
  end

  test "member cannot create customer" do
    customer = @acme_customer.store.customers.new

    policy = CustomerPolicy.new(@member, customer)

    refute policy.create?
  end

  test "owner cannot create customer in another organization" do
    customer = @another_customer.store.customers.new

    policy = CustomerPolicy.new(@owner, customer)

    refute policy.create?
  end

  test "owner can update customer in their organization" do
    policy = CustomerPolicy.new(@owner, @acme_customer)

    assert policy.update?
  end

  test "member cannot update customer" do
    policy = CustomerPolicy.new(@member, @acme_customer)

    refute policy.update?
  end

  test "owner cannot update customer from another organization" do
    policy = CustomerPolicy.new(@owner, @another_customer)

    refute policy.update?
  end

  test "owner can destroy customer in their organization" do
    policy = CustomerPolicy.new(@owner, @acme_customer)

    assert policy.destroy?
  end

  test "admin cannot destroy customer" do
    admin = User.create!(
      organization: @acme,
      email: "admin-destroy@acme-customer.test",
      password: "password123",
      first_name: "Admin",
      last_name: "Acme",
      role: "admin",
      active: true
    )

    policy = CustomerPolicy.new(admin, @acme_customer)

    refute policy.destroy?
  end

  test "member cannot destroy customer" do
    policy = CustomerPolicy.new(@member, @acme_customer)

    refute policy.destroy?
  end

  test "owner cannot destroy customer from another organization" do
    policy = CustomerPolicy.new(@owner, @another_customer)

    refute policy.destroy?
  end

  test "scope only returns customers from user's organization" do
    customers = Pundit.policy_scope(@owner, Customer)

    assert_includes customers, @acme_customer
    refute_includes customers, @another_customer
  end

  test "another organization owner only sees their organization's customers" do
    customers = Pundit.policy_scope(@another_owner, Customer)

    assert_includes customers, @another_customer
    refute_includes customers, @acme_customer
  end
end
