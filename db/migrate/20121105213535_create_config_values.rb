class CreateConfigValues < ActiveRecord::Migration
  def change
    create_table :config_values do |t|
      t.string :source_type
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
