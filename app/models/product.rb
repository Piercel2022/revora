class Product < ApplicationRecord
  belongs_to :store
  has_many :order_items, dependent: :restrict_with_exception

  validates :external_id,
    presence: true,
    uniqueness: { scope: :store_id }

  validates :title, presence: true

  validates :status,
    inclusion: { in: %w[active archived draft] }

  validates :currency, presence: true

  validates :price,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
end