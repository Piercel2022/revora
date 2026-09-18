require "test_helper"

class IntegrationTest < ActiveSupport::TestCase
  test "accepts a valid integration" do
    integration = Integration.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store",
      status: "active",
      external_id: "shopify-001",
      credentials: {
        access_token: "secret-token"
      }
    )

    assert integration.valid?
  end

  test "requires an organization" do
    integration = Integration.new(
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:organization], "must exist"
  end

  test "requires a provider" do
    integration = Integration.new(
      organization: organizations(:acme),
      name: "Shopify Main Store",
      kind: "store"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:provider], "is not included in the list"
  end

  test "accepts supported providers" do
    %w[shopify woocommerce prestashop].each do |provider|
      integration = Integration.new(
        organization: organizations(:acme),
        provider: provider,
        kind: "store",
        name: "#{provider} Integration"
      )

      assert integration.valid?, "#{provider} should be valid"
    end
  end

  test "rejects unsupported provider" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "magento",
      kind: "store",
      name: "Magento Integration"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:provider], "is not included in the list"
  end

  test "accepts supported kinds" do
    %w[store payment shipping marketing analytics].each do |kind|
      integration = Integration.new(
        organization: organizations(:acme),
        provider: "shopify",
        kind: kind,
        name: "#{kind.capitalize} Integration"
      )

      assert integration.valid?, "#{kind} should be valid"
    end
  end

  test "rejects unsupported kind" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "crm",
      name: "CRM Integration"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:kind], "is not included in the list"
  end

  test "defaults status to inactive" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store"
    )

    assert_equal "inactive", integration.status
  end

  test "accepts supported statuses" do
    %w[active inactive error].each do |status|
      integration = Integration.new(
        organization: organizations(:acme),
        provider: "shopify",
        kind: "store",
        name: "#{status.capitalize} Integration",
        status: status
      )

      assert integration.valid?, "#{status} should be valid"
    end
  end

  test "rejects unsupported status" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store",
      status: "disabled"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:status], "is not included in the list"
  end

  test "requires a name" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:name], "can't be blank"
  end

  test "requires a unique name within an organization" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store"
    )

    existing = Integration.create!(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store"
    )

    assert existing.persisted?
    assert_not integration.valid?
    assert_includes integration.errors[:name], "has already been taken"
  end

  test "allows the same name in another organization" do
    first = Integration.create!(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Main Store"
    )

    second = Integration.new(
      organization: organizations(:another),
      provider: "shopify",
      kind: "store",
      name: "Main Store"
    )

    assert first.persisted?
    assert second.valid?
  end

  test "store is optional" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "payment",
      name: "Shopify Payments"
    )

    assert integration.valid?
    assert_nil integration.store
  end

  test "accepts a store belonging to the same organization" do
    integration = Integration.new(
      organization: organizations(:acme),
      store: stores(:acme_store),
      provider: "shopify",
      kind: "store",
      name: "Shopify Main Store"
    )

    assert integration.valid?
  end

  test "rejects a store belonging to another organization" do
    integration = Integration.new(
      organization: organizations(:acme),
      store: stores(:another_store),
      provider: "shopify",
      kind: "store",
      name: "Cross Organization Integration"
    )

    assert_not integration.valid?
    assert_includes integration.errors[:store],
      "must belong to the same organization"
  end

  test "belongs to an organization" do
    association = Integration.reflect_on_association(:organization)

    assert_equal :belongs_to, association.macro
  end

  test "belongs to an optional store" do
    association = Integration.reflect_on_association(:store)

    assert_equal :belongs_to, association.macro
    assert association.options[:optional]
  end

  test "supports credentials as json" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Credentials"
    )

    integration.assign_attributes(
      "credentials" => {
        "access_token" => "secret-token",
        "shop_domain" => "acme.example.com"
      }
    )

      assert integration.valid?
      assert_equal "secret-token", integration.attributes["credentials"]["access_token"]
      assert_equal "acme.example.com", integration.attributes["credentials"]["shop_domain"]
    end

  test "allows external_id to be blank" do
    integration = Integration.new(
      organization: organizations(:acme),
      provider: "shopify",
      kind: "store",
      name: "Shopify Without External ID"
    )

    assert integration.valid?
    assert_nil integration.external_id
  end
end
