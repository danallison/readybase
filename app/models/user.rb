class User < ApplicationRecord
  has_secure_password
  has_secure_token

  # NOTE reset_password_token should be a secure token, but
  # we don't want it to generate on create.
  # has_secure_token :reset_password_token

  belongs_to :app
  has_many :apps, foreign_key: :owner_id

  validates :app_id, presence: true
  validates :email, presence: true
  validates :username, presence: true

  def self.find_by_email_or_username(email, username)
    user = self.where(email: email || username).first
    user = self.where(username: username).first if !user && username
    user
  end

  def writeable_attributes
    # NOTE Password is writeable but not persisted, so it is not included here.
    self.slice(:email, :username, :data, :roles, :belongs_to)
  end

  def apply_defaults
    defaults = app.config['defaults']['users']
    self.data = defaults['data'] if data.blank?
    self.roles = defaults['roles'] if roles.blank?
    self.reset_password_token = nil
  end

  def generate_reset_password_token
    self.reset_password_token = self.class.generate_unique_secure_token
  end

end
