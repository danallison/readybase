class CreateAppObjectAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :app_object_associations do |t|
      t.integer :app_id
      t.string :association_name
      t.integer :object_id
      t.string :associated_type
      t.integer :associated_id

      t.timestamps
    end
    add_index :app_object_associations, [:app_id, :associated_type, :associated_id], name: 'index_associations_on_app_id_and_associated_columns'
    add_index :app_object_associations, [:app_id, :object_id]
  end
end
