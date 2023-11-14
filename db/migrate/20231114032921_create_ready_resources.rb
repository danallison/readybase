class CreateReadyResources < ActiveRecord::Migration[7.1]
  def change
    create_table :ready_resources, id: :uuid do |t|
      t.references :ready_database, null: false, foreign_key: true, type: :uuid
      t.string :resource_type
      t.string :custom_id
      t.jsonb :data
      t.jsonb :belongs_to

      t.timestamps
    end

    add_index :ready_resources, [:ready_database_id, :resource_type, :custom_id], unique: true
    add_index :ready_resources, [:ready_database_id, :resource_type]
  end
end
