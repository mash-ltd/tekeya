class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer   :attache_id, null: false
      t.string    :attache_type, null: false
      t.integer   :attachable_id, null: false
      t.string    :attachable_type, null: false
      
      t.timestamps
    end
  end
end

