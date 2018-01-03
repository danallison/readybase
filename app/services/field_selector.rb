class FieldSelector < ApplicationService
  def self.select_fields(object_attrs, fields)
    selected_attrs = {}
    fields.each do |field|
      is_negation = field[0] == '-'
      field = field[1..-1] if is_negation
      if field == '*'
        selected_attrs = deep_clone_hash(object_attrs)
      elsif field.include?('.')
        field = field.split('.')
        oa = object_attrs
        sa = selected_attrs
        field.each_with_index do |r, i|
          oa = nil unless oa.is_a?(Hash)
          oa = oa[r] if oa
          next if i == (field.length - 1)
          sa[r] ||= {} if oa
          sa = sa[r] if sa
        end
        if oa && sa && is_negation
          sa.delete(field[-1])
        elsif oa && sa
          sa[field[-1]] = oa
        end
      elsif is_negation
        selected_attrs.delete(field)
      else
        selected_attrs[field] = object_attrs[field] if object_attrs.key?(field)
      end
    end
    selected_attrs
  end
end
