require "test_helper"

class OpportunityPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @opportunity = opportunities(:acme_opportunity)
    @another_opportunity = opportunities(:another_opportunity)
  end

  test "owner can index opportunities" do
    assert OpportunityPolicy.new(@owner, @opportunity).index?
  end

  test "member can index opportunities" do
    assert OpportunityPolicy.new(@member, @opportunity).index?
  end

  test "owner can show opportunity from own organization" do
    assert OpportunityPolicy.new(@owner, @opportunity).show?
  end

  test "member can show opportunity from own organization" do
    assert OpportunityPolicy.new(@member, @opportunity).show?
  end

  test "user cannot show opportunity from another organization" do
    assert_not OpportunityPolicy.new(@owner, @another_opportunity).show?
  end

  test "owner can create opportunity in own organization" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      customer: customers(:acme_customer),
      name: "Policy Opportunity",
      status: "open",
      value: 1000
    )

    assert OpportunityPolicy.new(@owner, opportunity).create?
  end

  test "member cannot create opportunity" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      customer: customers(:acme_customer),
      name: "Policy Opportunity",
      status: "open",
      value: 1000
    )

    assert_not OpportunityPolicy.new(@member, opportunity).create?
  end

  test "owner can update opportunity from own organization" do
    assert OpportunityPolicy.new(@owner, @opportunity).update?
  end

  test "member cannot update opportunity" do
    assert_not OpportunityPolicy.new(@member, @opportunity).update?
  end

  test "owner can destroy opportunity from own organization" do
    assert OpportunityPolicy.new(@owner, @opportunity).destroy?
  end

  test "member cannot destroy opportunity" do
    assert_not OpportunityPolicy.new(@member, @opportunity).destroy?
  end

  test "owner cannot destroy opportunity from another organization" do
    assert_not OpportunityPolicy.new(@owner, @another_opportunity).destroy?
  end

  test "scope only returns opportunities from user's organization" do
    opportunities = OpportunityPolicy::Scope.new(
      @owner,
      Opportunity.all
    ).resolve

    assert_includes opportunities, @opportunity
    assert_not_includes opportunities, @another_opportunity
  end

  test "member scope only returns opportunities from their organization" do
    opportunities = OpportunityPolicy::Scope.new(
      @member,
      Opportunity.all
    ).resolve

    assert_includes opportunities, @opportunity
    assert_not_includes opportunities, @another_opportunity
  end
end
