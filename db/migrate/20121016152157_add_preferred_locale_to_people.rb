class AddPreferredLocaleToPeople < ActiveRecord::Migration
  def change
    add_column :people, :preferred_locale, :string
  end
end
