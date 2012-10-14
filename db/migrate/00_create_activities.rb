class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string  :activity_type, null: false
      t.integer :entity_id, null: false
      t.string  :entity_type, null: false
      
      t.timestamps
    end
  end
end