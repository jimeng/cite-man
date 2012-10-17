class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :person_id
      t.string :provider
      t.string :name
      t.string :client_id
      t.string :client_key
      t.string :client_secret
      t.string :client_type
      t.string :uid

      t.timestamps
    end
  end
end
