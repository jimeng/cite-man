class AddCitationIdToClipboardItem < ActiveRecord::Migration
  def change
    add_column :clipboard_items, :citation_id, :string
  end
end
