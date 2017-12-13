class User < ApplicationRecord
  has_secure_password
  has_secure_token
  has_secure_token :reset_password_token

  belongs_to :app
  has_many :apps, foreign_key: :owner_id

  validates :app_id, presence: true
  validates :email, presence: true
  validates :username, presence: true

  before_create :set_reset_password_token_to_nil

  def self.unique_id_prefix
    'u'
  end

  def self.association_model
    UserAssociation
  end

  def self.association_foreign_key
    :user_id
  end

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:email, :username, :public_data, :private_data, :belongs_to, :created_at, :updated_at))
  end

  def public_attributes_for_api
    attributes_for_api.slice(:id, 'public_data')
  end

  def set_reset_password_token_to_nil
    self.reset_password_token = nil
  end

end
