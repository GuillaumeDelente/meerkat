# spec/workers/alert_worker_spec.rb
require 'spec_helper'
require 'sidekiq/testing'

describe AlertWorker do

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
      @worker = AlertWorker.new
    end

    it "doesn't retry the job if the alert is not found" do
      @worker.perform(0).should == 0
      expect(AlertWorker).to have(0).jobs
    end
    
    it "doesn't process the alert if unactive" do
      id = FactoryGirl.create(:alert, :active => false).id
      Nokogiri::HTML::Document.should_not_receive(:parse)
      @worker.perform(id)
    end
    
    it "process the alert if active" do
      id = FactoryGirl.create(:alert).id
      Nokogiri::HTML::Document.should_receive(:parse).and_call_original
      @worker.stub(:open) { File.open(File.expand_path('../html/alerts.html', __FILE__)) }
      @worker.perform(id)
    end
  end
end
