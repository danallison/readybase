class User < ApplicationRecord
  has_secure_password
  has_secure_token
  has_secure_token :reset_password_token

  belongs_to :app
  has_many :apps, foreign_key: :owner_id

  validates :app_id, presence: true
  validates :email, presence: true
  validates :username, presence: true

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:email, :username, :public_data, :private_data, :created_at, :updated_at))
  end

  def public_attributes_for_api
    attributes_for_api.slice(:id, 'public_data')
  end

  def self.unique_id_prefix
    'u'
  end
end
