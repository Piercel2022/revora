class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :segments, dependent: :destroy
  has_many :opportunities, dependent: :destroy

  validates :name, presence: true

  validates :slug,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  validates :status,
    inclusion: { in: %w[active suspended] }
end