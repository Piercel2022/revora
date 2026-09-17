class Customer < ApplicationRecord
  belongs_to :store

  validates :status,
    inclusion: { in: %w[active inactive] },
    allow_blank: true

  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    allow_blank: true
end