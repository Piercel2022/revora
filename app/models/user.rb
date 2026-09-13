
class User < ApplicationRecord
  belongs_to :organization

  has_secure_password

  enum :role, {
    owner: "owner",
    admin: "admin",
    member: "member"
  }

  validates :email,
    presence: true,
    uniqueness: { scope: :organization_id }

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :role,
    inclusion: { in: roles.keys }

  normalizes :email, with: ->(email) { email.strip.downcase }
end