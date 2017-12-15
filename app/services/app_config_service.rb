class AppConfigService

  def initialize(config)
    @config = config
  end

  def sanitize_for_read_access(object, current_user)
    roles = current_user.nil? ? ['@anonymous'] : current_user.roles
    object_type = object.is_a?(AppObject) ? object.type : "#{object.class}".downcase
    if object_type == 'users' && object.id == current_user.id
      # TODO add @self roles
    end
    role_rules = @config['access_rules'][object_type.pluralize]['read']['roles'].slice(*roles)
    return {} if role_rules.empty?
    can_access_all = role_rules.values.any?{|rules| rules == ['*'] }
    object_attrs = object.attributes_for_api
    return object_attrs if can_access_all
    attrs_for_each_role = role_rules.keys.map do |role|
      rules = role_rules[role]
      attrs_for_role = {}
      rules.each do |rule|
        is_negation = rule[0] == '-'
        rule = rule[1..-1] if is_negation
        if rule == '*'
          # TODO find a more efficient way to deep clone
          attrs_for_role = Marshal.load(Marshal.dump(object_attrs))
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
    attrs_for_each_role[0] # TODO account for multiple roles
  end

end
