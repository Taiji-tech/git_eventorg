class Reserve < ApplicationRecord
  belongs_to :event
  
  validates :nickname, presence: true
  validates :email, presence: true
  validates :event_id, presence: true
end
