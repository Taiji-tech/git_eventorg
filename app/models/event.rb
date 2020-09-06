class Event < ApplicationRecord
  belongs_to :user
  has_many :reserves
<<<<<<< HEAD
=======
  
  # 入力フォームのバリデーション
  validates :title, presence: true
  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :venue, presence: true
  validates :venue_pass, presence: true
  validates :content, presence: true
  validates :price, presence: true
  validates :capacity, presence: true
  validates :imgs, presence: true
  
  # active storage 使用
  has_many_attached :imgs
>>>>>>> dc21a8650bcc40630bd6fd1c0917b48181565942
end
