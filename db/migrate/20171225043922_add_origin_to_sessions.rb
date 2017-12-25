class AddOriginToSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :sessions, :origin, :string
  end
end
