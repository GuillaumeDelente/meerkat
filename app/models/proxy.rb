require 'resolv'

class Proxy < ActiveRecord::Base
  validates :ip, :port, presence: true
  validates :ip, format: { with: Resolv::IPv4::Regex }
  validates :port, numericality: { only_integer: true }

  def address
    "http://#{ip}:#{port}"
  end
end
