# spec/workers/alert_worker_spec.rb
require 'spec_helper'
require 'sidekiq/testing'

describe AlertWorker do

  before(:all) do
    @alertes_doc = Nokogiri::HTML(File.open(File.expand_path('../html/alertes.html', __FILE__)))
  end

  after(:each) do
    AlertWorker.jobs.clear
    ProxyWorker.jobs.clear
  end

  it "triggers the fetch of proxies if there are no proxies" do
    AlertWorker.new.perform(0).should == -1
    Sidekiq::Queue.new(:proxies).size.should == 1
  end

  it "doesn't triggers the fetch of proxies if proxies are being fetched" do
    ProxyWorker.perform_async
    AlertWorker.new.perform(0).should == -1
    Sidekiq::Queue.new(:proxies).size.should == 1
  end
end
