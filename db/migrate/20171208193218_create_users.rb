class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :password_digest
      t.string :token
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.jsonb :data

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :token, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
