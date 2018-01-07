class RemoveApps < ActiveRecord::Migration[5.0]
  def up
    drop_table :apps

    # users table
    remove_index :users, [:app_id, :email]#, unique: true
    remove_index :users, [:app_id, :username]#, unique: true
    remove_index :users, [:app_id, :token]#, unique: true
    remove_index :users, [:app_id, :reset_password_token]#, unique: true
    remove_column :users, :app_id, :integer
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :token, unique: true
    add_index :users, :reset_password_token, unique: true

    # app_objects table
    remove_index :app_objects, :app_id
    remove_index :app_objects, [:app_id, :type]
    remove_column :app_objects, :app_id, :integer
    add_index :app_objects, :type

    # user_associations table
    remove_index :user_associations, [:app_id, :associated_type, :associated_id]#, name: 'index_user_associations_on_app_id_and_associated_columns'
    remove_index :user_associations, [:app_id, :user_id]
    remove_column :user_associations, :app_id, :integer
    add_index :user_associations, [:associated_type, :associated_id], name: 'index_user_associations_on_associated_columns'
    add_index :user_associations, :user_id

    # app_object_associations table
    remove_index :app_object_associations, [:app_id, :associated_type, :associated_id]#, name: 'index_object_associations_on_app_id_and_associated_columns'
    remove_index :app_object_associations, [:app_id, :object_id]
    remove_column :app_object_associations, :app_id, :integer
    add_index :app_object_associations, [:associated_type, :associated_id], name: 'index_object_associations_on_associated_columns'
    add_index :app_object_associations, :object_id

    # sessions table
    remove_index :sessions, [:app_id, :token]#, unique: true
    remove_index :sessions, [:app_id, :user_id]
    remove_column :sessions, :app_id, :integer
    add_index :sessions, :token, unique: true
    add_index :sessions, :user_id
  end

  def down
    create_table :apps do |t|
      t.string :name
      t.string :public_id
      t.integer :owner_id
      t.jsonb :config, default: {}
      t.jsonb :public_data, default: {}

      t.timestamps
    end
    add_index :apps, :public_id, unique: true

    # users table
    add_column :users, :app_id, :integer
    add_index :users, [:app_id, :email], unique: true
    add_index :users, [:app_id, :username], unique: true
    add_index :users, [:app_id, :token], unique: true
    add_index :users, [:app_id, :reset_password_token], unique: true
    remove_index :users, :email#, unique: true
    remove_index :users, :username#, unique: true
    remove_index :users, :token#, unique: true
    remove_index :users, :reset_password_token#, unique: true

    # app_objects table
    add_column :app_objects, :app_id, :integer
    add_index :app_objects, :app_id
    add_index :app_objects, [:app_id, :type]
    remove_index :app_objects, :type

    # user_associations table
    add_column :user_associations, :app_id, :integer
    add_index :user_associations, [:app_id, :associated_type, :associated_id], name: 'index_user_associations_on_app_id_and_associated_columns'
    add_index :user_associations, [:app_id, :user_id]
    remove_index :user_associations, [:associated_type, :associated_id]#, name: 'index_user_associations_on_associated_columns'
    remove_index :user_associations, :user_id

    # app_object_associations table
    add_column :app_object_associations, :app_id, :integer
    add_index :app_object_associations, [:app_id, :associated_type, :associated_id], name: 'index_object_associations_on_app_id_and_associated_columns'
    add_index :app_object_associations, [:app_id, :object_id]
    remove_index :app_object_associations, [:associated_type, :associated_id]#, name: 'index_object_associations_on_associated_columns'
    remove_index :app_object_associations, :object_id

    # sessions table
    add_column :sessions, :app_id, :integer
    add_index :sessions, [:app_id, :token], unique: true
    add_index :sessions, [:app_id, :user_id]
    remove_index :sessions, :token#, unique: true
    remove_index :sessions, :user_id
  end
end
