class Segment < ApplicationRecord
  belongs_to :organization

  validates :name,
    presence: true,
    uniqueness: { scope: :organization_id }

  validates :status,
    inclusion: { in: %w[active archived] }
end
