class AppObject < ApplicationRecord
  belongs_to :app
  validates :app_id, presence: true
  validates :type, presence: true
  # validates belongs_to

  # NOTE Rails reserves the `type` column for model subclass inheretence,
  # which we don't need (yet), so disabling that here.
  self.inheritance_column = :nil

  def apply_defaults
    self.type ||= 'object'
  end

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:type, :belongs_to, :data, :created_at, :updated_at))
  end

end
