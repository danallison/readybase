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

  # TODO Clean this up and move it to the correct file
  test "config service sanitizes correctly" do
    user = User.first
    user.roles = ['default']
    user.data = {
      'public' => {},
      'private' => {}
    }
    app = App.create(name: 'blah', owner_id: user.id)
    object = AppObject.new(app_id: app.id, type: 'foo')
    object.data = {
      a: {
        b: {
          c: 1,
          d: 2
        }
      },
      x: 3,
      z: 9
    }
    object.save!
    app.config['access_rules']['foos'] = {
      'read' => {
        'roles' => {
          user.roles[0] => ['id','data.a', 'data.x', '-data.a.b.c','belongs_to.a.b.c', 'dafsdaf']
        }
      }
    }
    app.save!
    sanitized_object = app.config_service.sanitize_for_read_access(object, user)
    sanitized_object = app.config_service.sanitize_for_read_access(user, user)
    puts sanitized_object
  end

end
