# spec/workers/proxy_worker_spec.rb
require 'spec_helper'

describe ProxyWorker do
  it "should put proxies on the database" do
    Proxy.all.length.should == 0
    doc = Nokogiri::HTML(File.open(File.expand_path('../html/proxies.html', __FILE__)))
    Nokogiri::HTML::Document.should_receive(:parse).and_return(doc)
    ProxyWorker.new.perform
    Proxy.all.length.should == 20
  end
end
