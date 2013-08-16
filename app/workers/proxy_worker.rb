class ProxyWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :proxies

  def perform
    #begin
    if ENV['PROXY_LIST_URL'].nil?
      raise "PROXY_LIST_URL not set!"
    end
    
    doc = Nokogiri::HTML(open(ENV['PROXY_LIST_URL'])) do |config|
      config.strict.nonet
    end

    ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ports = doc.xpath("/html/body/div/div/table/tr/td[2]/text()").map(&:text)
    ips.map! { |ip| Base64.decode64(ip.text[/\"(.*)\"/, 1]) }
    proxies = ips.zip(ports)
    
    Proxy.delete_all
    # Reset autoincrement count as it's needed by how alert workers
    # choose a proxy
    ActiveRecord::Base.connection.reset_pk_sequence!(Proxy.table_name)
    proxies.each {|ip, port| Proxy.create(ip: ip, port: port)}
    #rescue
    # Bugsnag.notify(RuntimeError.new("Proxy parsing failed"), {
    #                  :content => doc,
    #                })
    #end
  end
end
