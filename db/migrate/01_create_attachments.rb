class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer   :activity_id, null: false
      t.string    :activity_type, null: false
      
      t.timestamps
    end
  end
end

