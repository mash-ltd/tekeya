class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string  :activity_type, null: false
      t.string  :content
      t.integer :entity_id
      t.string  :entity_type
      
      t.timestamps
    end
  end
end