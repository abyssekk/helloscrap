class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :password, length: { minimum: 3}
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true, presence: true
  validates :last_name, presence: true, length: { maximum: 255 }
  validates :first_name, presence: true, length: { maximum: 255 }
end
