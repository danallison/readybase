class User < ApplicationRecord
  has_secure_password
  has_secure_token

  belongs_to :app

  validates :app_id, presence: true
  validates :email, presence: true
  validates :username, presence: true

  def attributes_for_api
    self.slice(:id, :email, :username, :data, :created_at, :updated_at)
  end
end
