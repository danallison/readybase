class ScopeTranslator
  @@scope_parser = nil

  def initialize(app_id)
    @app_id = app_id
  end

  def translate(scope_string)
    scope_definition = parser.parse(scope_string).compile
    scope_from_definition(scope_definition)
  end

  private

  def self.parser
    return @@scope_parser if @@scope_parser
    reload_parser!
    @@scope_parser
  end

  def self.reload_parser!
    Treetop.load("#{Rails.root}/app/services/grammars/scope_grammar.treetop")
    @@scope_parser = ScopeParser.new
  end

  def parser
    self.class.parser
  end

  def scope_from_definition(definition)
    object_type = definition[:object_type]
    left = definition[:condition][:left]
    operator = definition[:condition][:operator]
    right = definition[:condition][:right]
    if left.is_a?(Hash)
      left = scope_from_definition({object_type: object_type, condition: left})
    end
    if right.is_a?(Hash)
      right = scope_from_definition({object_type: object_type, condition: right})
    end
    if operator == :belongs_to
      model = object_type == 'user' ? User : AppObject
      if left == "@#{object_type}"
        prefix, id = ApplicationRecord.unique_id_to_prefix_and_id(right)
        sql = model.where_associated(
          app_id: @app_id,
          associated_type: prefix,
          associated_id: id
        ).to_sql
      elsif right == "@#{object_type}"
        prefix, id = ApplicationRecord.unique_id_to_prefix_and_id(left)
        foreign_key = prefix == 'u' ? :user_id : :object_id
        sql = model.where_has_associated(
          app_id: @app_id,
          foreign_key => id
        ).to_sql
      end
      where_string = ' WHERE '
      where_index = sql.index(where_string)
      return sql[(where_index + where_string.length)..-1]
    end
    "#{left} #{operator} #{right}"
  end
end
