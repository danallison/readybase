class CreateUserAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_associations do |t|
      t.integer :app_id
      t.integer :user_id
      t.string :association_name
      t.string :associated_type
      t.integer :associated_id

      t.timestamps
    end
    add_index :user_associations, [:app_id, :associated_type, :associated_id], name: 'index_user_associations_on_app_id_and_associated_columns'
    add_index :user_associations, [:app_id, :user_id]
  end
end
