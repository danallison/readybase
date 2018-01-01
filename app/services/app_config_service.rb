class AppConfigService

  def initialize(config)
    @config = config
  end

  def apply_scope(scope, current_user, access_type, action = nil)
    # TODO
  end

  def sanitize_for_access(object, current_user, access_type, action = nil, object_attrs = nil)
    roles = (current_user.nil? || current_user.id.nil?) ? ['@anonymous'] : current_user.roles
    object_type = object.is_a?(AppObject) ? object.type : "#{object.class}".downcase
    if current_user && object.is_a?(User) && object.id == current_user.id
      roles = roles.map {|r| "@self.#{r}" } + roles
    end
    object_attrs ||= access_type == 'read' ? object.readable_attributes : object.writeable_attributes
    begin
      role_rules = @config['access_rules'][object_type.pluralize][access_type]['roles'].slice(*roles)
    rescue
      return object_attrs
    end
    return {} if role_rules.empty?
    can_access_all = role_rules.values.any?{|rules| rules == ['*'] }
    return object_attrs if can_access_all
    attrs_for_each_role = roles.map do |role|
      rules = role_rules[role]
      rules = rules[normalize_action(action)] if rules.is_a?(Hash)
      next unless rules
      FieldSelector.select_fields(object_attrs, rules)
    end
    merged_attrs = {}
    attrs_for_each_role.compact.reverse_each do |attrs|
      merged_attrs = merge_recursively(merged_attrs, attrs)
    end
    merged_attrs
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

  def merge_recursively(hash0, hash1)
    hash1.each do |key, val|
      if hash0[key].is_a?(Hash) && val.is_a?(Hash)
        merge_recursively(hash0[key], val)
      else
        hash0[key] = val
      end
    end
    hash0
  end

end
