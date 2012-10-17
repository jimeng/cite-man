class AddPreferredStyleToPeople < ActiveRecord::Migration
  def change
    add_column :people, :preferred_style, :string
  end
end
