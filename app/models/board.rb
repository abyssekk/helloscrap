class Board < ApplicationRecord
    belongs_to :user
    validates :title, presence: true
    validates :body, presence: true

    validates :url, length: {maximum: 100}
    validates :title, length: {maximum: 100}
    validates :body, length: {maximum: 10000}
    validates :notice, length: {maximum: 10000}
end
