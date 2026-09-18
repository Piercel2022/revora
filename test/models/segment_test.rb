require "test_helper"

class SegmentTest < ActiveSupport::TestCase
  test "valid segment" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "New VIP Customers",
      description: "High-value customers",
      status: "active"
    )

    assert segment.valid?
  end

  test "requires organization" do
    segment = Segment.new(
      name: "New VIP Customers",
      status: "active"
    )

    assert_not segment.valid?
    assert_includes segment.errors[:organization], "must exist"
  end

  test "requires name" do
    segment = Segment.new(
      organization: organizations(:acme),
      status: "active"
    )

    assert_not segment.valid?
    assert_includes segment.errors[:name], "can't be blank"
  end

  test "accepts valid statuses" do
    organization = organizations(:acme)

    %w[active archived].each do |status|
      segment = Segment.new(
        organization: organization,
        name: "Segment #{status}",
        status: status
      )

      assert segment.valid?
    end
  end

  test "rejects invalid status" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "New Invalid Status Segment",
      status: "invalid"
    )

    assert_not segment.valid?
    assert_includes segment.errors[:status], "is not included in the list"
  end

  test "defaults status to active" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "New Default Status Segment"
    )

    assert_equal "active", segment.status
  end

  test "allows description to be blank" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "New Description Optional Segment",
      status: "active"
    )

    assert segment.valid?
  end

  test "name must be unique within organization" do
    Segment.create!(
      organization: organizations(:acme),
      name: "Unique Segment",
      status: "active"
    )

    duplicate = Segment.new(
      organization: organizations(:acme),
      name: "Unique Segment",
      status: "active"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "same name is allowed in another organization" do
    Segment.create!(
      organization: organizations(:acme),
      name: "Shared Segment Name",
      status: "active"
    )

    segment = Segment.new(
      organization: organizations(:another),
      name: "Shared Segment Name",
      status: "active"
    )

    assert segment.valid?
  end
end
