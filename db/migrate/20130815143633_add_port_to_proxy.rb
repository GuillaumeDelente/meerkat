class AddPortToProxy < ActiveRecord::Migration
  def change
    add_column :proxies, :port, :integer
  end
end
