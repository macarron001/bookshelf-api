class UserBook < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :user_id, presence: true
  validates :book_id, presence: true
  validates :rating, presence: true, inclusion: 0..5

  scope :to_read, ->(user) {where(finish_date: nil, user_id: user)}
  scope :finished, ->(user) { where.not(finish_date: nil, user_id: user)}
end
