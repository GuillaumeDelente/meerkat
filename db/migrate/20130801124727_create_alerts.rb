class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :name
      t.string :query
      t.integer :frequency
      t.references :user, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
