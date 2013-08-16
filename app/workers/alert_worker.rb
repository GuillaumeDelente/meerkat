# -*- coding: utf-8 -*-
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
    last_ad_index = ads.find_index {|node| /\/(\d+)\.htm/.match(node['href'])[1] == last_ad_id}
    if last_ad_index
      ads = ads.slice(0, last_ad_index)
    elsif alert.last_ad_date
      # If we have a last known ad, check if it hasn't been removed
      #dates = new_ads.map {|node| node.css('div.date div').map {|e| e.text}}
      dates = get_date_from_ads ads
      older_ad_index = dates.find_index {|date| Chronic.parse(date) < last_ad_date}
      ads = ads.slice(0, older_ad_index) if older_ad_index
    end
    process_new_ads(ads, alert)
  end

  def parse_test(doc)
    #ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
    ip = "failed"
    doc.css("span.ip").each do |item|
      ip = item.text
    end
    ip
  end

  def process_new_ads(new_ads, alert)
    if new_ads.empty?
      return [0]
    end
    links = new_ads.map {|node| node['href']}
    images = new_ads.css('img').map do |node| 
      src = node['src']
      src =~ /\.gif$/ ? nil : src
    end
    dates = get_date_from_ads(new_ads)
    details_nodes = new_ads.css('div.detail')
    titles = details_nodes.map { |title| sanitize_if_not_nil title.at_css('div.title')}
    prices = details_nodes.map { |price| sanitize_if_not_nil price.at_css('div.price')}
    locations = details_nodes.map { |location| sanitize_if_not_nil location.at_css('div.placement')}
    last_ad = new_ads.first
    last_ad_id = /\/(\d+)\.htm/.match(last_ad['href'])[1]
    last_ad_date = last_ad.css('div.date div').map {|e| e.text}
    last_ad_date = Chronic.parse(dates.first)
    alert.last_ad_date = last_ad_date
    alert.last_ad_id = last_ad_id
    alert.save
    [last_ad_date, links, dates, images, prices, titles, locations]
  end

  def get_date_from_ads(ads)
    ads.css('div.date div').each_slice(2).map {|date| "#{date[0].text} #{date[1].text}"}
  end

  def sanitize_if_not_nil(s)
    s ? s.text.gsub(/[^[[:print:]]]/, '') : nil
  end
end
