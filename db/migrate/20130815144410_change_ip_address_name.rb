class ChangeIpAddressName < ActiveRecord::Migration
  def change
    rename_column :proxies, :ip_address, :ip
  end
end
