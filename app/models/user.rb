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

  def unique_id
    "u_#{id}"
  end

  def self.unique_id_to_id(u_id)
    split_u_id = u_id.split('_')
    prefix, id = split_u_id
    id = id.to_i
    id if id && prefix == 'u' && split_u_id.length == 2
  end

  def self.find_by_unique_id(u_id)
    self.find_by_id(self.unique_id_to_id(u_id))
  end

  def self.find_by_app_id_and_unique_id(app_id, u_id)
    self.find_by_app_id_and_id(app_id, self.unique_id_to_id(u_id))
  end
end
