require "test_helper"

class IntegrationPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @integration = integrations(:acme_shopify)
    @another_integration = integrations(:another_shopify)
  end

  test "owner can index integrations" do
    assert IntegrationPolicy.new(@owner, @integration).index?
  end

  test "member can index integrations" do
    assert IntegrationPolicy.new(@member, @integration).index?
  end

  test "owner can show integration from own organization" do
    assert IntegrationPolicy.new(@owner, @integration).show?
  end

  test "member can show integration from own organization" do
    assert IntegrationPolicy.new(@member, @integration).show?
  end

  test "user cannot show integration from another organization" do
    assert_not IntegrationPolicy.new(@owner, @another_integration).show?
  end

  test "owner can create integration in own organization" do
    integration = Integration.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      provider: "shopify",
      kind: "store",
      name: "Policy Integration"
    )

    assert IntegrationPolicy.new(@owner, integration).create?
  end

  test "member cannot create integration" do
    integration = Integration.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      provider: "shopify",
      kind: "store",
      name: "Policy Integration"
    )

    assert_not IntegrationPolicy.new(@member, integration).create?
  end

  test "owner can update integration from own organization" do
    assert IntegrationPolicy.new(@owner, @integration).update?
  end

  test "member cannot update integration" do
    assert_not IntegrationPolicy.new(@member, @integration).update?
  end

  test "owner can destroy integration from own organization" do
    assert IntegrationPolicy.new(@owner, @integration).destroy?
  end

  test "member cannot destroy integration" do
    assert_not IntegrationPolicy.new(@member, @integration).destroy?
  end

  test "owner cannot destroy integration from another organization" do
    assert_not IntegrationPolicy.new(@owner, @another_integration).destroy?
  end

  test "scope only returns integrations from user's organization" do
    integrations = IntegrationPolicy::Scope.new(
      @owner,
      Integration.all
    ).resolve

    assert_includes integrations, @integration
    assert_not_includes integrations, @another_integration
  end

  test "member scope only returns integrations from their organization" do
    integrations = IntegrationPolicy::Scope.new(
      @member,
      Integration.all
    ).resolve

    assert_includes integrations, @integration
    assert_not_includes integrations, @another_integration
  end
end
