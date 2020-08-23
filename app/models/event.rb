class Event < ApplicationRecord
  belongs_to :user
  has_many :reserves
  
  # 入力フォームのバリデーション
  validates :title, presence: true
  validates :start, presence: true
  validates :venue, presence: true
  validates :content, presence: true
  validates :capacity, presence: true
end
