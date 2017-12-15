class AppObject < ApplicationRecord
  belongs_to :app
  validates :app_id, presence: true
  validates :type, presence: true
  validate :type_complies_with_app_config

  # NOTE Rails reserves the `type` column for model subclass inheretence,
  # which we don't need (yet), so disabling that here.
  self.inheritance_column = :nil

  def type_complies_with_app_config
    allowed_object_types = app.config['allowed_object_types']
    no_type_restriction = allowed_object_types.include?('*')
    unless no_type_restriction || allowed_object_types.include?(type)
      errors.add(:type, "'#{type}' is not a valid object type")
    end
  end

  def apply_defaults
    self.type ||= 'object'
  end

  def attributes_for_api
    {'id' => unique_id}.merge(self.slice(:type, :belongs_to, :data, :created_at, :updated_at))
  end

end
