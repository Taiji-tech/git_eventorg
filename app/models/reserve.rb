class Reserve < ApplicationRecord
  belongs_to :event
  has_one :pay
  
  validates :nickname, presence: true
  validates :email, presence: true
  validates :event_id, presence: true
end
