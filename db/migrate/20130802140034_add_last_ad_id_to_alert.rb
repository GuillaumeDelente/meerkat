class AddLastAdIdToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :last_ad_id, :integer
  end
end
