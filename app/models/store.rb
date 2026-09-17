class Store < ApplicationRecord
  belongs_to :organization

  has_many :customers, dependent: :destroy

  validates :name, presence: true

  validates :platform,
    presence: true,
    inclusion: { in: %w[shopify woocommerce prestashop] }

  validates :external_id,
    presence: true,
    uniqueness: { scope: :organization_id }

  validates :currency, presence: true
  validates :timezone, presence: true

  validates :status,
    inclusion: { in: %w[active paused disconnected] }
end
