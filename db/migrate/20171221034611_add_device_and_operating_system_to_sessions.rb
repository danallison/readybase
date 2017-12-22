class AddDeviceAndOperatingSystemToSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :sessions, :device_id, :string
    add_column :sessions, :device, :string
    add_column :sessions, :operating_system, :string
    add_column :sessions, :browser, :string
    add_column :sessions, :last_ip, :string
    add_index :sessions, [:app_id, :user_id]
  end
end
