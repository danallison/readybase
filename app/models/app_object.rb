class AppObject < ApplicationRecord
  belongs_to :app
  validates :app_id, presence: true
  # validates belongs_to

  after_save :process_associations

  # NOTE Rails reserves the `type` column for model subclass inheretence,
  # which we don't need (yet), so disabling that here.
  self.inheritance_column = :nil

  def self.unique_id_prefix
    'o'
  end

  def self.where_associated(association_params)
    object_id_sql = AppObjectAssociation.where(association_params).to_sql.gsub(
      'SELECT "app_object_associations".* FROM ',
      'SELECT "app_object_associations"."object_id" FROM '
    )
    self.where("\"app_objects\".\"id\" IN (#{object_id_sql})")
  end

  def attributes_for_api
    {id: unique_id}.merge(self.slice(:type, :belongs_to, :data, :created_at, :updated_at))
  end

  def process_associations(force = false)
    if belongs_to_changed? || force == true
      AppObjectAssociation.transaction do
        AppObjectAssociation.where(app_id: app_id, object_id: id).delete_all
        belongs_to.each do |association_name, uids|
          uids = [uids] if uids.is_a?(String)
          # TODO error if uids in not an array
          uids.each do |uid|
            associated_type, associated_id = uid.split('_')
            # TODO validate association (or not?)
            AppObjectAssociation.create({
              app_id: app_id,
              object_id: id,
              association_name: association_name,
              associated_type: associated_type,
              associated_id: associated_id.to_i
            })
          end
        end
      end
    end
  end

end
