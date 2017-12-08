class User < ApplicationRecord
  has_secure_password
  has_secure_token
  validates :email, presence: true
  validates :username, presence: true
end
