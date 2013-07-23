class Proxy < ActiveRecord::Base
  validates :ip_address, presence: true, format: { with: Resolv::IPv4::Regex }
  validates :port, presence: true
end
