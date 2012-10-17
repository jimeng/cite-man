class AddDefaultStyleToSources < ActiveRecord::Migration
  def change
    add_column :sources, :default_style, :string
  end
end
