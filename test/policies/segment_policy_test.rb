require "test_helper"

class SegmentPolicyTest < ActiveSupport::TestCase
  setup do
    @owner = users(:owner)
    @member = users(:member)
    @segment = segments(:acme_segment)
    @another_segment = segments(:another_segment)
  end

  test "owner can index segments" do
    assert SegmentPolicy.new(@owner, @segment).index?
  end

  test "member can index segments" do
    assert SegmentPolicy.new(@member, @segment).index?
  end

  test "owner can show segment from own organization" do
    assert SegmentPolicy.new(@owner, @segment).show?
  end

  test "member can show segment from own organization" do
    assert SegmentPolicy.new(@member, @segment).show?
  end

  test "user cannot show segment from another organization" do
    assert_not SegmentPolicy.new(@owner, @another_segment).show?
  end

  test "owner can create segment in own organization" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "Policy Segment",
      description: "Segment created for policy testing",
      status: "active"
    )

    assert SegmentPolicy.new(@owner, segment).create?
  end

  test "member cannot create segment" do
    segment = Segment.new(
      organization: organizations(:acme),
      name: "Policy Segment",
      description: "Segment created for policy testing",
      status: "active"
    )

    assert_not SegmentPolicy.new(@member, segment).create?
  end

  test "owner can update segment from own organization" do
    assert SegmentPolicy.new(@owner, @segment).update?
  end

  test "member cannot update segment" do
    assert_not SegmentPolicy.new(@member, @segment).update?
  end

  test "owner can destroy segment from own organization" do
    assert SegmentPolicy.new(@owner, @segment).destroy?
  end

  test "member cannot destroy segment" do
    assert_not SegmentPolicy.new(@member, @segment).destroy?
  end

  test "owner cannot destroy segment from another organization" do
    assert_not SegmentPolicy.new(@owner, @another_segment).destroy?
  end

  test "scope only returns segments from user's organization" do
    segments = SegmentPolicy::Scope.new(@owner, Segment.all).resolve

    assert_includes segments, @segment
    assert_not_includes segments, @another_segment
  end

  test "member scope only returns segments from their organization" do
    segments = SegmentPolicy::Scope.new(@member, Segment.all).resolve

    assert_includes segments, @segment
    assert_not_includes segments, @another_segment
  end
end
