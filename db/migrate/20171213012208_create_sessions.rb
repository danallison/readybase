class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.integer :app_id
      t.integer :user_id
      t.string :token
      t.string :user_agent
      t.datetime :expires_at

      t.timestamps
    end
    add_index :sessions, [:app_id, :token], unique: true
  end
end
