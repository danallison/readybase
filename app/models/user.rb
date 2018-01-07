class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  has_secure_password
  has_secure_token

  before_save :downcase_email_and_username

  # NOTE reset_password_token should be a secure token, but
  # we don't want it to generate on create.
  # has_secure_token :reset_password_token

  has_many :user_associations, dependent: :destroy

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :username, presence: true

  def self.find_by_email_or_username(email, username)
    email = email.downcase if email
    username = username.downcase if username
    user = self.where(email: email || username).first if (email || username) =~ VALID_EMAIL_REGEX
    user = self.where(username: username || email).first unless user
    user
  end

  def writeable_attributes
    # NOTE Password is writeable but not persisted, so it is not included here.
    self.slice(:email, :username, :data, :roles, :belongs_to)
  end

  def apply_defaults
    defaults = Rails.application.config.readybase_config['defaults']['users']
    self.data = defaults['data'] if data.blank?
    self.roles = defaults['roles'] if roles.blank?
    self.username ||= email
    downcase_email_and_username
    self.reset_password_token = nil
  end

  def downcase_email_and_username
    self.email = email.downcase
    self.username = username.downcase
  end

  def generate_reset_password_token
    self.reset_password_token = self.class.generate_unique_secure_token
  end

end
