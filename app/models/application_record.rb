class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_validation :apply_defaults, on: :create
  after_save :process_associations

  def self.unique_id_prefix
    self.to_s.downcase.gsub('app', '')[0]
  end

  def self.unique_id_to_id(uid)
    split_uid = uid.split('_')
    prefix, id = split_uid
    id = id.to_i
    id if id && prefix == unique_id_prefix && split_uid.length == 2
  end

  def self.unique_id_to_prefix_and_id(uid)
    split_uid = uid.split('_')
    prefix, id = split_uid
    id = id.to_i
    [prefix, id] if id && prefix && split_uid.length == 2
  end

  def self.find_by_unique_id(uid)
    self.find_by_id(self.unique_id_to_id(uid))
  end

  def self.find_by_app_id_and_unique_id(app_id, uid)
    self.find_by_app_id_and_id(app_id, self.unique_id_to_id(uid))
  end

  def self.association_model
    "#{self}Association".constantize rescue nil
  end

  def self.association_foreign_key
    "#{self}_id".downcase.gsub('app', '').to_sym
  end

  def self.where_associated(association_params)
    association_foreign_key_sql = association_model.where(association_params).to_sql.gsub(
      "SELECT \"#{association_model.table_name}\".* FROM ",
      "SELECT \"#{association_model.table_name}\".\"#{association_foreign_key}\" FROM "
    )
    self.where("\"#{table_name}\".\"id\" IN (#{association_foreign_key_sql})")
  end

  def apply_defaults
  end

  def attributes_for_api
    raise "#{self.class} has not defined its 'attributes_for_api'"
  end

  def public_attributes_for_api
    attributes_for_api
  end

  def unique_id_prefix
    self.class.unique_id_prefix
  end

  def unique_id
    "#{unique_id_prefix}_#{id}"
  end

  def association_model
    self.class.association_model
  end

  def association_foreign_key
    self.class.association_foreign_key
  end

  def process_associations(force = false)
    return unless association_model
    if belongs_to_changed? || force == true
      association_model.transaction do
        association_model.where(app_id: app_id, association_foreign_key => id).delete_all
        belongs_to.each do |association_name, uids|
          uids = [uids] if uids.is_a?(String)
          # TODO error if uids in not an array
          association_name = association_name.singularize
          uids.each do |uid|
            associated_type, associated_id = self.class.unique_id_to_prefix_and_id(uid)
            # TODO validate association (or not?)
            association_model.create({
              app_id: app_id,
              association_foreign_key => id,
              association_name: association_name,
              associated_type: associated_type,
              associated_id: associated_id
            })
          end
        end
      end
    end
  end

end
