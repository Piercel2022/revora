
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      organization: organizations(:acme),
      email: "new-user@acme-store.test",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      role: "member",
      active: true
    )

    assert user.valid?
    assert user.authenticate("password123")
  end

  test "belongs to an organization" do
    assert_respond_to users(:owner), :organization
    assert_equal organizations(:acme), users(:owner).organization
  end

  test "requires an organization" do
    user = User.new(
      email: "user@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_not user.valid?
    assert_includes user.errors[:organization], "must exist"
  end

  test "requires an email" do
    user = User.new(
      organization: organizations(:acme),
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "normalizes email" do
    user = User.new(
      organization: organizations(:acme),
      email: "  USER@ACME-STORE.TEST  ",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert user.valid?
    assert_equal "user@acme-store.test", user.email
  end

  test "requires a unique email within the same organization" do
    existing = users(:owner)

    user = User.new(
      organization: organizations(:acme),
      email: existing.email,
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "allows the same email in different organizations" do
    organization = Organization.create!(
      name: "Second Store",
      slug: "second-store",
      status: "active"
    )

    user = User.new(
      organization: organization,
      email: users(:owner).email,
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert user.valid?
  end

  test "requires a first name" do
    user = User.new(
      organization: organizations(:acme),
      email: "user@test.com",
      password: "password123",
      last_name: "Doe"
    )

    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "requires a last name" do
    user = User.new(
      organization: organizations(:acme),
      email: "user@test.com",
      password: "password123",
      first_name: "John"
    )

    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "defaults role to member" do
    user = User.new(
      organization: organizations(:acme),
      email: "user@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_equal "member", user.role
  end

  test "accepts owner role" do
    user = User.new(
      organization: organizations(:acme),
      email: "owner-test@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      role: "owner"
    )

    assert user.valid?
  end

  test "accepts admin role" do
    user = User.new(
      organization: organizations(:acme),
      email: "admin-test@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      role: "admin"
    )

    assert user.valid?
  end

  test "accepts member role" do
    user = User.new(
      organization: organizations(:acme),
      email: "member-test@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      role: "member"
    )

    assert user.valid?
  end

  
  test "rejects an invalid role" do
    user = User.new(
      organization: organizations(:acme),
      email: "invalid-role@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_raises(ArgumentError) do
      user.role = "superadmin"
    end
  end


  test "defaults active to true" do
    user = User.new(
      organization: organizations(:acme),
      email: "active-test@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    assert_equal true, user.active
  end

  test "can be inactive" do
    user = User.new(
      organization: organizations(:acme),
      email: "inactive-test@test.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe",
      active: false
    )

    assert user.valid?
    assert_not user.active
  end

  test "has secure password" do
    user = users(:owner)

    assert user.authenticate("password123")
    assert_not user.authenticate("wrong-password")
  end
end
