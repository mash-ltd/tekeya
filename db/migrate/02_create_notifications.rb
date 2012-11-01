class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string    :notification_type, null: false
      t.integer   :subject_id, null: false
      t.string    :subject_type, null: false
      t.integer   :entity_id, null: false
      t.string    :entity_type, null: false
      
      t.timestamps
    end
  end
end