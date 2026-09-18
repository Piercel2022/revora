
require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid organization" do
    organization = Organization.new(
      name: "New Store",
      slug: "new-store",
      status: "active"
    )

    assert organization.valid?
    assert_equal "active", organization.status
  end

  test "requires a name" do
    organization = Organization.new(slug: "missing-name")

    assert_not organization.valid?
    assert_includes organization.errors[:name], "can't be blank"
  end

  test "requires a slug" do
    organization = Organization.new(name: "Missing Slug")

    assert_not organization.valid?
    assert_includes organization.errors[:slug], "can't be blank"
  end

  test "requires a unique slug" do
    existing = organizations(:acme)

    organization = Organization.new(
      name: "Another Store",
      slug: existing.slug
    )

    assert_not organization.valid?
    assert_includes organization.errors[:slug], "has already been taken"
  end

  test "accepts a valid slug" do
    valid_slugs = [
      "fresh-store",
      "new-store",
      "acme-store-2026",
      "store123"
    ]

    valid_slugs.each do |slug|
      organization = Organization.new(
        name: "Test Store",
        slug: slug
      )

      assert organization.valid?, "Expected #{slug.inspect} to be valid"
    end
  end

  test "rejects an invalid slug" do
    invalid_slugs = [
      "Acme",
      "acme_store",
      "acme store",
      "-acme",
      "acme-",
      "acme--store"
    ]

    invalid_slugs.each do |slug|
      organization = Organization.new(
        name: "Test Store",
        slug: slug
      )

      assert_not organization.valid?, "Expected #{slug.inspect} to be invalid"
    end
  end

  test "accepts active status" do
    organization = Organization.new(
      name: "Active Store",
      slug: "active-store",
      status: "active"
    )

    assert organization.valid?
  end

  test "accepts suspended status" do
    organization = Organization.new(
      name: "Suspended Store",
      slug: "suspended-store",
      status: "suspended"
    )

    assert organization.valid?
  end

  test "rejects an invalid status" do
    organization = Organization.new(
      name: "Disabled Store",
      slug: "disabled-store",
      status: "disabled"
    )

    assert_not organization.valid?
    assert_includes organization.errors[:status], "is not included in the list"
  end

  test "has many users" do
    assert_respond_to Organization.new, :users
  end

  test "has many stores" do
    assert_respond_to Organization.new, :stores
  end

  test "has many segments" do
    organization = organizations(:acme)

    segment = Segment.create!(
      organization: organization,
      name: "Test Segment",
      status: "active"
    )

    assert_includes organization.segments, segment
  end
end
