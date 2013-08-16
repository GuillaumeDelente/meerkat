# spec/workers/alert_worker_spec.rb
require 'spec_helper'
require 'sidekiq/testing'

describe AlertWorker do

  def initialize
    @alertes_doc = Nokogiri::HTML(File.open(File.expand_path('../html/alertes.html', __FILE__)))
  end

  it "runs in the alert queue" do
    expect(AlertWorker).to be_processed_in :alert
  end

  it "triggers the fetch of proxies if there are no proxies" do
    AlertWorker.new.perform(0).should == -1
    expect(ProxyWorker).to have(1).jobs
  end

  it "doesn't triggers the fetch of proxies if proxies are being fetched" do
    ProxyWorker.perform_async
    AlertWorker.new.perform(0).should == -1
    expect(ProxyWorker).to have(1).jobs
  end

  it "doesn't retry the job if the alert is not found" do
    FactoryGirl.create_list(:proxy, 20)
    AlertWorker.new.perform(0).should == 0
    expect(AlertWorker).to have(0).jobs
  end
end
