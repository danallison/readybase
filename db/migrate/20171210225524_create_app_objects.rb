class CreateAppObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :app_objects do |t|
      t.integer :app_id
      t.string :type
      t.jsonb :belongs_to, default: {}
      t.jsonb :data, default: {}

      t.timestamps
    end
    add_index :app_objects, :app_id
    add_index :app_objects, [:app_id, :type]
  end
end
