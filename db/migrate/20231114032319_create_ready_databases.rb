class CreateReadyDatabases < ActiveRecord::Migration[7.1]
  def change
    create_table :ready_databases, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :domain, null: false, default: 'localhost'
      t.string :custom_id
      t.jsonb :data

      t.timestamps
    end

    add_index :ready_databases, [:domain, :custom_id], unique: true
  end
end
