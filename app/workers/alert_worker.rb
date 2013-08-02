class AlertWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => true
  
  def perform(alert_id)
    proxy_count = Proxy.count
    if proxy_count == 0
      if Sidekiq::Queue.new("proxy").size == 0
        ProxyScraperWorker.perform_async
      end
      # Mark the job as failed to be retried
      return -1
    end
    begin
      alert = Alert.find(alert_id)
    rescue ActiveRecord::RecordNotFound => e
      # Mark the job as succeded as the alert has
      # been deleted
      return 0
    end
    if not alert.active?
      return 0
    end
    proxy = Proxy.find(alert_id % proxy_count + 1)
    options = { :proxy => proxy }
    doc = Nokogiri::HTML(open(alert.query, options)) do |config|
      config.strict.nonet
    end
    parse(doc)
  end

  def parse(doc)

  end

  def parse_test(doc)
    #ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ip = "failed"
    doc.css("span.ip").each do |item|
      ip = item.text
    end
    ip
  end
end
