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
    doc = Nokogiri::HTML(File.open("/home/guillaume/Desktop/lbc.html"))
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
    last_ad_index = ads.find {|node| /\/(\d+)\.htm/.match(node['href'])[1] == last_ad_id}
    if last_ad_index
      ads = ads.slice(0, last_ad_index)
    elsif alert.last_ad_date
      # If we have a last known ad, check if it hasn't been removed
      #dates = new_ads.map {|node| node.css('div.date div').map {|e| e.text}}
      dates = ads.css('div.date div').each_slice(2).map {|date| "#{date[0].text} #{date[1].text}"}
      older_ad_index = dates.find_index {|date| Chronic.parse(date) < last_ad_date}
#      return [dates, Chronic.parse(dates[0]), older_ad_index]
      ads = ads.slice(0, older_ad_index) if older_ad_index
      
#      new_dates = dates.reverse_each.drop_while { |date| Chronic.parse("#{date[0]} #{date[1]}") < last_ad_date }
#      new_ads = new_ads[0, new_dates.length]
    end
    process_new_ads(ads)
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
    if new_ads.empty?
      return [0]
    end
    links = new_ads.map {|node| node['href']}
    images = new_ads.map {|node| node.at_css('img')['src']}
    dates = new_ads.map {|node| node.css('div.date div').map {|date| date.text}}
    details_nodes = new_ads.map {|node| node.css('div.detail')}
    titles = details_nodes.map { |node| node.at_css('div.title').text.gsub(/[^0-9A-Za-z ]/, '')}
    prices = details_nodes.map { |node| price = node.at_css('div.price'); price.nil? ? nil : price.text}
    locations = details_nodes.map { |node| node.at_css('div.placement').text}
    last_ad = new_ads.first
    last_ad_id = /\/(\d+)\.htm/.match(last_ad['href'])[1]
    last_ad_date = last_ad.css('div.date div').map {|e| e.text}
    last_ad_date = Chronic.parse("#{last_ad_date[0]} #{last_ad_date[1]}")
    [links, dates, images, prices, titles, locations]
  end
end
