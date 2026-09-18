class Opportunity < ApplicationRecord
  belongs_to :organization
  belongs_to :store, optional: true
  belongs_to :customer, optional: true

  validate :store_belongs_to_organization
  validate :customer_belongs_to_organization

  validates :name,
    presence: true,
    uniqueness: { scope: :organization_id }

  validates :status,
    inclusion: {
      in: %w[open won lost]
    }

  validates :value,
    numericality: { greater_than_or_equal_to: 0 }

  private

  def store_belongs_to_organization
    return if store.nil? || organization.nil?

    return if store.organization_id == organization_id

    errors.add(:store, "must belong to the same organization")
  end

  def customer_belongs_to_organization
    return if customer.nil? || organization.nil?

    return if customer.store&.organization_id == organization_id

    errors.add(:customer, "must belong to the same organization")
  end
end
