class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # validation
  validates :nickname, presence: true
  
  # association
  has_many :events
  has_many :pays
  has_one :tenant
end
