class CreateProxies < ActiveRecord::Migration
  def change
    create_table :proxies do |t|
      t.string :ip_address
      t.string :port

      t.timestamps
    end
  end
end
