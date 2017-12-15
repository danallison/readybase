class App < ApplicationRecord
  has_many :users
  belongs_to :user, foreign_key: :owner_id
  has_secure_token :public_id
  validate :config_is_valid
  alias_method :owner, :user

  def attributes_for_api
    {id: public_id}.merge(self.slice(:name, :config, :public_data, :created_at, :updated_at))
  end

  def reset_config
    self.config = Rails.application.config.default_app_config
  end

  def apply_defaults
    reset_config
  end

  def config_service
    @config_service ||= AppConfigService.new(config)
  end

  def config_is_valid
    errors.add(:config, 'config cannot be empty') if config.empty?
    ['allowed_domains','allowed_object_types','user_roles'].each {|key| validate_config_array_of_strings(key) }
  end

  def validate_config_array_of_strings(key)
    errors.add(:config, "config.#{key} must be an array") unless config[key].is_a?(Array)
    errors.add(:config, "config.#{key} must only contain strings") unless config[key].all? {|s| s.is_a?(String) }
  end
end
