class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :family_name
      t.string :full_name
      t.string :given_name
      t.string :user_id

      t.timestamps
    end
  end
end
