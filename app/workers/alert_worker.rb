# -*- coding: utf-8 -*-
class AlertWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => true


  def initialize
    Chronic.locale = :'fr-FR'
  end

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
    options = { :proxy => proxy.ip_address }
    doc = Nokogiri::HTML(File.open("/home/guillaume/Desktop/lbc-empty.html"))
#    doc = Nokogiri::HTML(open(alert.query, options)) do |config|
#      config.strict.nonet
#    end
    parse(doc, alert)
  end

  def parse(doc, alert)
    last_ad_id = alert.last_ad_id.to_s
    last_ad_date = alert.last_ad_date
    ads = doc.css('div.list-lbc a')
    if ads.empty? and not doc.at_css('h2#result_ad_not_found').nil?
      Bugsnag.notify(RuntimeError.new("Ad list parsing failed"), {
                       :content => doc
                     })
    end
    new_ads = ads.take_while {|node| /\/(\d+)\.htm/.match(node['href'])[1] != last_ad_id}
    if (new_ads.size == ads.size and alert.last_ad_date != nil)
      dates = new_ads.map {|node| node.css('div.date div').map {|e| e.text}}
      new_dates = dates.reverse_each.drop_while { |date| Chronic.parse("#{date[0]} #{date[1]}") < last_ad_date }
      new_ads = new_ads[0, new_dates.length]
    end
    process_new_ads(new_ads)
  end

  def parse_test(doc)
    #ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ip = "failed"
    doc.css("span.ip").each do |item|
      ip = item.text
    end
    ip
  end

  def process_new_ads(new_ads)
    ids = new_ads.map {|node| /\/(\d+)\.htm/.match(node['href'])[1]}
    ids
  end
end
