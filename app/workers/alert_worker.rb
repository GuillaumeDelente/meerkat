class AlertWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(alert_id)
    doc = Nokogiri::HTML(open(ENV['PROXY_LIST_URL'])) do |config|
      config.strict.nonet
    end
    ips = doc.xpath("/html/body/div/div/table/tr/td[1 and not(@colspan)]/script/text()").to_a
  end
end
