class Order < ApplicationRecord
  belongs_to :store
  belongs_to :customer, optional: true
  has_many :order_items, dependent: :destroy

  validates :external_id,
    presence: true,
    uniqueness: { scope: :store_id }

  validates :order_number,
    presence: true,
    uniqueness: { scope: :store_id }

  validates :status,
    inclusion: {
      in: %w[pending paid fulfilled cancelled refunded]
    }

  validates :currency, presence: true

  validates :subtotal,
    :tax,
    :shipping,
    :discount,
    :total,
    numericality: { greater_than_or_equal_to: 0 }

  validate :customer_belongs_to_store

  private

  def customer_belongs_to_store
    return if customer.nil? || store.nil?

    return if customer.store_id == store_id

    errors.add(:customer, "must belong to the same store")
  end
end
