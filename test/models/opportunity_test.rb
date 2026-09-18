require "test_helper"

class OpportunityTest < ActiveSupport::TestCase
  test "valid opportunity" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      customer: customers(:acme_customer),
      name: "New Enterprise Opportunity",
      status: "open",
      value: 15000.00,
      expected_close_at: Time.current
    )

    assert opportunity.valid?
  end

  test "requires organization" do
    opportunity = Opportunity.new(
      name: "New Opportunity",
      status: "open",
      value: 1000
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:organization], "must exist"
  end

  test "requires name" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      status: "open",
      value: 1000
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:name], "can't be blank"
  end

  test "accepts valid statuses" do
    %w[open won lost].each do |status|
      opportunity = Opportunity.new(
        organization: organizations(:acme),
        name: "Opportunity #{status}",
        status: status,
        value: 1000
      )

      assert opportunity.valid?, "Expected #{status} to be valid"
    end
  end

  test "rejects invalid status" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Invalid Status Opportunity",
      status: "invalid",
      value: 1000
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:status], "is not included in the list"
  end

  test "defaults status to open" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Default Status Opportunity"
    )

    assert_equal "open", opportunity.status
  end

  test "defaults value to zero" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Default Value Opportunity"
    )

    assert_equal BigDecimal("0"), opportunity.value
  end

  test "rejects negative value" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Negative Value Opportunity",
      value: -1
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:value], "must be greater than or equal to 0"
  end

  test "allows zero value" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Zero Value Opportunity",
      value: 0
    )

    assert opportunity.valid?
  end

  test "store is optional" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Organization Level Opportunity",
      status: "open",
      value: 1000
    )

    assert opportunity.valid?
  end

  test "customer is optional" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "Customer Optional Opportunity",
      status: "open",
      value: 1000
    )

    assert opportunity.valid?
  end

  test "name must be unique within organization" do
    existing_opportunity = opportunities(:acme_opportunity)

    duplicate = Opportunity.new(
      organization: existing_opportunity.organization,
      name: existing_opportunity.name,
      status: "open",
      value: 1000
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "same name is allowed in another organization" do
    existing_opportunity = opportunities(:acme_opportunity)

    opportunity = Opportunity.new(
      organization: organizations(:another),
      name: existing_opportunity.name,
      status: "open",
      value: 1000
    )

    assert opportunity.valid?
  end

  test "belongs to organization" do
    opportunity = opportunities(:acme_opportunity)

    assert_equal organizations(:acme), opportunity.organization
  end

  test "belongs to store" do
    opportunity = opportunities(:acme_opportunity)

    assert_equal stores(:acme_store), opportunity.store
  end

  test "belongs to customer" do
    opportunity = opportunities(:acme_opportunity)

    assert_equal customers(:acme_customer), opportunity.customer
  end

  test "expected_close_at is optional" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      name: "No Close Date Opportunity",
      status: "open",
      value: 1000
    )

    assert opportunity.valid?
  end

  test "rejects store belonging to another organization" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      store: stores(:another_store),
      name: "Cross Organization Store Opportunity",
      status: "open",
      value: 1000
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:store],
      "must belong to the same organization"
  end

  test "rejects customer belonging to another organization" do
    opportunity = Opportunity.new(
      organization: organizations(:acme),
      customer: customers(:another_customer),
      name: "Cross Organization Customer Opportunity",
      status: "open",
      value: 1000
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:customer],
      "must belong to the same organization"
  end
end
