class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :external_id,
    uniqueness: { scope: :order_id },
    allow_blank: true

  validates :title, presence: true

  validates :quantity,
    numericality: {
      only_integer: true,
      greater_than: 0
    }

  validates :unit_price,
    :discount,
    :tax,
    :total,
    numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true

  validate :product_belongs_to_order_store

  private

  def product_belongs_to_order_store
    return if product.nil? || order.nil?
    return if product.store_id == order.store_id

    errors.add(:product, "must belong to the same store")
  end
end
