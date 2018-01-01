class AppConfigService

  def initialize(config)
    @config = config
  end

  def sanitize_for_access(object, current_user, access_type, action = nil, object_attrs = nil)
    roles = (current_user.nil? || current_user.id.nil?) ? ['@anonymous'] : current_user.roles
    object_type = object.is_a?(AppObject) ? object.type : "#{object.class}".downcase
    if current_user && object.is_a?(User) && object.id == current_user.id
      roles = roles.map {|r| "@self.#{r}" } + roles
    end
    role_rules = @config['access_rules'][object_type.pluralize][access_type]['roles'].slice(*roles)
    return {} if role_rules.empty?
    can_access_all = role_rules.values.any?{|rules| rules == ['*'] }
    object_attrs ||= access_type == 'read' ? object.readable_attributes : object.writeable_attributes
    return object_attrs if can_access_all
    attrs_for_each_role = roles.map do |role|
      rules = role_rules[role]
      rules = rules[normalize_action(action)] if rules.is_a?(Hash)
      next unless rules
      attrs_for_role = {}
      rules.each do |rule|
        is_negation = rule[0] == '-'
        rule = rule[1..-1] if is_negation
        if rule == '*'
          # TODO find a more efficient way to deep clone
          attrs_for_role = JSON.parse(object_attrs.to_json)
        elsif rule.include?('.')
          rule = rule.split('.')
          oa = object_attrs
          ra = attrs_for_role
          rule.each_with_index do |r, i|
            oa = nil unless oa.is_a?(Hash)
            oa = oa[r] if oa
            next if i == (rule.length - 1)
            ra[r] ||= {} if oa
            ra = ra[r] if ra
          end
          if oa && ra && is_negation
            ra.delete(rule[-1])
          elsif oa && ra
            ra[rule[-1]] = oa
          end
        elsif is_negation
          attrs_for_role.delete(rule)
        else
          attrs_for_role[rule] = object_attrs[rule] if object_attrs.key?(rule)
        end
      end
      attrs_for_role
    end
    attrs_for_each_role.compact[0] || {} # TODO account for multiple roles
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
