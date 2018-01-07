class AppConfigService < ApplicationService

  @@config = Rails.application.config.readybase_config

  def self.apply_scope(scope, current_user, access_type, action = nil)
    # TODO
  end

  def self.sanitize_for_access(object, current_user, access_type, action = nil, object_attrs = nil)
    roles = (current_user.nil? || current_user.id.nil?) ? ['anonymous'] : current_user.roles
    object_type = object.is_a?(AppObject) ? object.type : "#{object.class}".downcase
    if current_user && object.is_a?(User) && object.id == current_user.id
      roles += roles.map {|r| "self.#{r}" }
    end
    object_attrs ||= access_type == 'read' ? object.readable_attributes : object.writeable_attributes
    begin
      role_rules = @@config["#{access_type}_access_rules"][object_type.pluralize].slice(*roles)
    rescue
      role_rules = @@config["#{access_type}_access_rules"]['objects'].slice(*roles)
    rescue
      # TODO Should access rules be required?
      return object_attrs
    end
    return {} if role_rules.empty?
    can_access_all = role_rules.values.any?{|rules| rules == ['*'] }
    return object_attrs if can_access_all
    merged_attrs = nil
    roles.each do |role|
      rules = role_rules[role]
      rules = rules[normalize_action(action)] if rules.is_a?(Hash)
      next unless rules
      selected_attrs = FieldSelector.select_fields(object_attrs, rules)
      if merged_attrs
        merged_attrs = merge_recursively(merged_attrs, selected_attrs)
      else
        merged_attrs = selected_attrs
      end
    end
    merged_attrs || {}
  end

  private

  def normalize_action(action)
    {
      get: 'read',
      post: 'create',
      put: 'update',
      patch: 'update',
      delete: 'delete'
    }[action.downcase.to_sym] || action.downcase
  end

end
