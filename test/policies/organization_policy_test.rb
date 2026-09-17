require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  test "owner can show their organization" do
    user = users(:owner)
    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    assert policy.show?
  end

  test "member can show their organization" do
    user = users(:member)
    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    assert policy.show?
  end

  test "user cannot show another organization" do
    user = users(:owner)
    organization = organizations(:another)

    policy = OrganizationPolicy.new(user, organization)

    refute policy.show?
  end

  test "owner can update their organization" do
    user = users(:owner)
    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    assert policy.update?
  end

  test "admin can update their organization" do
    user = users(:owner)
    user.update!(role: "admin")

    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    assert policy.update?
  end

  test "member cannot update their organization" do
    user = users(:member)
    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    refute policy.update?
  end

  test "owner can destroy their organization" do
    user = users(:owner)
    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    assert policy.destroy?
  end

  test "admin cannot destroy their organization" do
    user = users(:owner)
    user.update!(role: "admin")

    organization = organizations(:acme)

    policy = OrganizationPolicy.new(user, organization)

    refute policy.destroy?
  end

  test "scope only returns the user's organization" do
    user = users(:owner)

    scoped_organizations = Pundit.policy_scope!(user, Organization)

    assert_equal [organizations(:acme)], scoped_organizations.to_a
  end
end
