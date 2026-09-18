class Integration < ApplicationRecord
  belongs_to :organization
  belongs_to :store, optional: true

  validate :store_belongs_to_organization

  validates :provider,
    inclusion: {
      in: %w[shopify woocommerce prestashop]
    }

  validates :kind,
    inclusion: {
      in: %w[store payment shipping marketing analytics]
    }

  validates :name,
    presence: true,
    uniqueness: { scope: :organization_id }

  validates :status,
    inclusion: {
      in: %w[active inactive error]
    }

  private

  def store_belongs_to_organization
    return if store.nil? || organization.nil?

    return if store.organization_id == organization_id

    errors.add(:store, "must belong to the same organization")
  end
end
