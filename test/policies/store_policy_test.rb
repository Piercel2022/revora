require "test_helper"

class StorePolicyTest < ActiveSupport::TestCase
  setup do
    @acme = organizations(:acme)
    @another = organizations(:another)

    @owner = users(:owner)
    @member = users(:member)

    @another_owner = User.create!(
      organization: @another,
      email: "owner@another-store.test",
      password: "password123",
      first_name: "Another",
      last_name: "Owner",
      role: "owner",
      active: true
    )

    @acme_store = stores(:acme_store)
    @another_store = stores(:another_store)
  end

  test "owner can index stores" do
    policy = StorePolicy.new(@owner, Store)

    assert policy.index?
  end

  test "member can index stores" do
    policy = StorePolicy.new(@member, Store)

    assert policy.index?
  end

  test "owner can show store in their organization" do
    policy = StorePolicy.new(@owner, @acme_store)

    assert policy.show?
  end

  test "member can show store in their organization" do
    policy = StorePolicy.new(@member, @acme_store)

    assert policy.show?
  end

  test "user cannot show store from another organization" do
    policy = StorePolicy.new(@owner, @another_store)

    refute policy.show?
  end

  test "owner can create store" do
    store = @acme.stores.new

    policy = StorePolicy.new(@owner, store)

    assert policy.create?
  end

  test "admin can create store" do
    admin = User.create!(
      organization: @acme,
      email: "admin@acme-store.test",
      password: "password123",
      first_name: "Admin",
      last_name: "Acme",
      role: "admin",
      active: true
    )

    store = @acme.stores.new

    policy = StorePolicy.new(admin, store)

    assert policy.create?
  end

  test "member cannot create store" do
    store = @acme.stores.new

    policy = StorePolicy.new(@member, store)

    refute policy.create?
  end

  test "owner can update store in their organization" do
    policy = StorePolicy.new(@owner, @acme_store)

    assert policy.update?
  end

  test "member cannot update store" do
    policy = StorePolicy.new(@member, @acme_store)

    refute policy.update?
  end

  test "owner cannot update store from another organization" do
    policy = StorePolicy.new(@owner, @another_store)

    refute policy.update?
  end

  test "owner can destroy store in their organization" do
    policy = StorePolicy.new(@owner, @acme_store)

    assert policy.destroy?
  end

  test "admin cannot destroy store" do
    admin = User.create!(
      organization: @acme,
      email: "admin-destroy@acme-store.test",
      password: "password123",
      first_name: "Admin",
      last_name: "Acme",
      role: "admin",
      active: true
    )

    policy = StorePolicy.new(admin, @acme_store)

    refute policy.destroy?
  end

  test "member cannot destroy store" do
    policy = StorePolicy.new(@member, @acme_store)

    refute policy.destroy?
  end

  test "owner cannot destroy store from another organization" do
    policy = StorePolicy.new(@owner, @another_store)

    refute policy.destroy?
  end

  test "scope only returns stores from user's organization" do
    stores = Pundit.policy_scope(@owner, Store)

    assert_includes stores, @acme_store
    refute_includes stores, @another_store
  end

  test "another organization owner only sees their organization's stores" do
    stores = Pundit.policy_scope(@another_owner, Store)

    assert_includes stores, @another_store
    refute_includes stores, @acme_store
  end
end
