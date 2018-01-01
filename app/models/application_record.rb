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
    unless association_params[:app_id]
      raise 'app_id is required'
    end
    association_sql = association_model
                      .where(association_params)
                      .select(association_foreign_key)
                      .to_sql
    self.where("\"#{table_name}\".\"id\" IN (#{association_sql})")
  end

  def self.where_has_associated(association_params)
    unless association_params[:app_id]
      raise 'app_id is required'
    end
    if association_params[:object_id]
      model_of_association = AppObjectAssociation
    elsif association_params[:user_id]
      model_of_association = UserAssociation
    end
    association_params[:associated_type] = unique_id_prefix
    association_sql = model_of_association
                      .where(association_params)
                      .select(:associated_id)
                      .to_sql
    self.where("\"#{table_name}\".\"id\" IN (#{association_sql})")
  end

  def apply_defaults
  end

  def read_only_atttributes
    {'id' => unique_id}.merge(self.slice(:created_at, :updated_at))
  end

  def writeable_attributes
    {}
  end

  def readable_attributes
    read_only_atttributes.merge(writeable_attributes)
  end

  def attributes_for_api
    readable_attributes
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
