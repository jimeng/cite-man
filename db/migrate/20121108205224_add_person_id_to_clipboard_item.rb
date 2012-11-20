class AddPersonIdToClipboardItem < ActiveRecord::Migration
  def change
    add_column :clipboard_items, :person_id, :string
  end
end
