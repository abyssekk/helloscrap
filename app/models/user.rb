class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3}, on: :create
  validates :password, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :email, uniqueness: true, presence: true
  validates :nickname, presence: true, length: { maximum: 255 }
  validates :reset_password_token, uniqueness: true, allow_nil: true

  has_many :boards, dependent: :destroy
  enum role: { general: 0, admin: 1 }
end
