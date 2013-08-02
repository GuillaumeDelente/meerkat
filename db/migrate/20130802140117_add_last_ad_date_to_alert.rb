class AddLastAdDateToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :last_ad_date, :datetime
  end
end
