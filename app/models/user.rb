class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  
  # avtive storage
  has_one_attached :image
  
  
  # validation
  validates :nickname, presence: true
  
  # association
  has_many :events
  has_one :tenant
  
  # after confirmation
  def after_confirmation
    UserMailer.mail_user_registered(self).deliver_now
  end
  
end
