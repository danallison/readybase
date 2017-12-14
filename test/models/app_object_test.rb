require 'test_helper'

class AppObjectTest < ActiveSupport::TestCase

  test "requires a valid app_id" do
    object = AppObject.new(app_id: 0)
    assert_raises(ActiveRecord::RecordInvalid) do
      object.save!
    end
  end

  test "type defaults to 'object'" do
    object = AppObject.new(app_id: App.first.id)
    object.save!
    assert_equal('object', object.type)
  end

  test "processes associations correctly on save" do
    app_id = App.first.id
    object_1 = AppObject.create(app_id: app_id)
    object_2 = AppObject.create(app_id: app_id)
    object_2.belongs_to = { parents: [object_1.unique_id] }
    object_2.save!
    associations = AppObjectAssociation.where(app_id: app_id, object_id: object_2.id)
    assert_equal(1, associations.length)
    association = associations.first
    assert_equal('parents'.singularize, association.association_name)
    assert_equal('o', association.associated_type)
    assert_equal(object_1.id, association.associated_id)
    # Test deletion
    object_2.belongs_to = { parents: [] }
    object_2.save!
    associations = AppObjectAssociation.where(app_id: app_id, object_id: object_2.id)
    assert_equal(0, associations.length)
  end

end
