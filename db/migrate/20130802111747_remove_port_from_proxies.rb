class RemovePortFromProxies < ActiveRecord::Migration
  def change
    remove_column :proxies, :port, :integer
  end
end
