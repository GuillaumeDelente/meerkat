class Proxy < ActiveRecord::Base
  validates :ip_address, presence: {strict: true}
  validate :valid_proxy

  def valid_proxy
    begin
      address = URI.parse(ip_address)
      if address.scheme.nil? or address.host.nil? or address.port.nil?
        raise URI::InvalidURIError, 'Scheme, host or port missing' 
      end
    rescue URI::InvalidURIError => e
      errors.add(:ip_address, "is not valid " + e.message)
    end
  end
end
