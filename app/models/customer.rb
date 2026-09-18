class Customer < ApplicationRecord
  belongs_to :store

  has_many :orders, dependent: :destroy
  has_many :opportunities, dependent: :destroy

  validates :status,
    inclusion: { in: %w[active inactive] },
    allow_blank: true

  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    allow_blank: true
end