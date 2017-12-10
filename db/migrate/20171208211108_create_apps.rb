class CreateApps < ActiveRecord::Migration[5.0]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :public_id
      t.integer :owner_id
      t.jsonb :config, default: {}
      t.jsonb :public_data, default: {}

      t.timestamps
    end
    add_index :apps, :public_id, unique: true
  end
end
