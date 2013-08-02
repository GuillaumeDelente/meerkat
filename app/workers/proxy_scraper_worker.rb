class ProxyScraperWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    if ENV['PROXY_LIST_URL'].nil?
      Bugsnag.notify(RuntimeError.new("PROXY_LIST_URL not set!"))
      return
    end

    doc = Nokogiri::HTML(open(ENV['PROXY_LIST_URL'])) do |config|
      config.strict.nonet
    end
    ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ports = doc.xpath("/html/body/div/div/table/tr/td[2]/text()").to_a
    if ips.empty? or ports.empty?
      Bugsnag.notify(RuntimeError.new("Proxy parsing failed"), {
                       :content => doc,
                     })
      return
    end
    ips.map! { |ip| Base64.decode64(ip.text[/\"(.*)\"/, 1]) }
    proxies = ips.zip(ports).map {|ip, port| "http://#{ip}:#{port}"}

    Proxy.delete_all
    # Reset autoincrement count as it's needed by how alert workers
    # choose a proxy
    ActiveRecord::Base.connection.reset_pk_sequence!(Proxy.table_name)
    proxies.each {|proxy_address| Proxy.create(ip_address: proxy_address)}
  end
end
