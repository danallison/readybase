class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def attributes_for_api
    raise "#{self.class} has not defined its 'attributes_for_api'"
  end

  def public_attributes_for_api
    attributes_for_api
  end

  def self.unique_id_prefix
    raise "#{self.class} has not defined its 'unique_id_prefix'"
  end

  def unique_id_prefix
    self.class.unique_id_prefix
  end

  def unique_id
    "#{unique_id_prefix}_#{id}"
  end

  def self.unique_id_to_id(u_id)
    split_u_id = u_id.split('_')
    prefix, id = split_u_id
    id = id.to_i
    id if id && prefix == unique_id_prefix && split_u_id.length == 2
  end

  def self.find_by_unique_id(u_id)
    self.find_by_id(self.unique_id_to_id(u_id))
  end

  def self.find_by_app_id_and_unique_id(app_id, u_id)
    self.find_by_app_id_and_id(app_id, self.unique_id_to_id(u_id))
  end
end
