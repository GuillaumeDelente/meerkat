# spec/workers/alert_worker_spec.rb
require 'spec_helper'
require 'sidekiq/testing'

describe AlertWorker do

  def initialize
    @alertes_doc = Nokogiri::HTML(File.open(File.expand_path('../html/alertes.html', __FILE__)))
  end

  before(:each) do
    Nokogiri::HTML::Document.stub(:parse) {@alertes_doc}
  end


  it "runs in the alert queue" do
    expect(AlertWorker).to be_processed_in :alert
  end


  context "without proxies" do
    it "triggers the fetch of proxies if there are no proxies" do
      AlertWorker.new.perform(0).should == -1
      expect(ProxyWorker).to have(1).jobs
    end
    
    it "doesn't triggers the fetch of proxies if proxies are being fetched" do
      ProxyWorker.perform_async
      AlertWorker.new.perform(0).should == -1
      expect(ProxyWorker).to have(1).jobs
    end
  end

  context "with proxies" do
    
    before(:each) do
      ActiveRecord::Base.connection.reset_pk_sequence!(Proxy.table_name)
      FactoryGirl.create_list(:proxy, 20)
    end

    it "doesn't retry the job if the alert is not found" do
      AlertWorker.new.perform(0).should == 0
      expect(AlertWorker).to have(0).jobs
    end
    
    it "doesn't process the alert if unactive" do
      id = FactoryGirl.create(:alert, :active => false).id
      Nokogiri::HTML::Document.should_not_receive(:parse)
      AlertWorker.new.perform(id)
    end
    
    it "process the alert if active" do
      id = FactoryGirl.create(:alert).id
#      Nokogiri::HTML::Document.should_receive(:parse)
      worker = AlertWorker.new
#      worker.should_receive(:open)
      worker.stub(:open)
      worker.perform(id)
      
    end
  end
end
