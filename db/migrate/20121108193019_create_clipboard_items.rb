class CreateClipboardItems < ActiveRecord::Migration
  def change
    create_table :clipboard_items do |t|
      t.text :citation

      t.timestamps
    end
  end
end
