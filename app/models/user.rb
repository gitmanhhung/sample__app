class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  before_save{email.downcase!}
  validates :name, presence: true,
    length: {maximum: Settings.validate.name_max}
  validates :email, presence: true,
    length: {maximum: Settings.validate.email_max},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true
  has_secure_password

  def self.digest string
    cost =  if ActiveModel::SecurePassword.min_cost
              BCrypt::Engine::MIN_COST
            else
              BCrypt::Engine.cost
            end
    BCrypt::Password.create string, cost: cost
  end
end
