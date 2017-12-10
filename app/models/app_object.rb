class AppObject < ApplicationRecord
  belongs_to :app
  validates :app_id, presence: true
  # validates belongs_to

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:type, :belongs_to, :data, :created_at, :updated_at))
  end

  def self.unique_id_prefix
    'o'
  end
end
