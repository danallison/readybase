class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :app_id
      t.string :email
      t.string :username
      t.string :password_digest
      t.string :token
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.jsonb :data, default: {}

      t.timestamps
    end
    add_index :users, [:app_id, :email], unique: true
    add_index :users, [:app_id, :username], unique: true
    add_index :users, [:app_id, :token], unique: true
    add_index :users, [:app_id, :reset_password_token], unique: true
  end
end
