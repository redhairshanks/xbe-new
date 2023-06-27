class CreateDatabaseNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :database_notifications, id: :uuid do |t|
      t.string :event 
      t.json :payload
      t.timestamps
    end
  end
end
