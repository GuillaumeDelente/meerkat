class ProxyScraperWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    doc = Nokogiri::HTML(open(ENV['PROXY_LIST_URL'])) do |config|
      config.strict.nonet
    end
    ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ports = doc.xpath("/html/body/div/div/table/tr/td[2]/text()").to_a
    ips.map! { |ip| Base64.decode64(ip.text[/\"(.*)\"/, 1]) }
    ips.zip(ports) { |ip, port| Proxy.create(ip_address: ip, port: port.text.to_i)}
  end
end
