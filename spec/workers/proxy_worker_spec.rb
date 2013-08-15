# spec/workers/proxy_worker_spec.rb
require 'spec_helper'

describe ProxyWorker do
  before(:all) do
    @proxies_doc = Nokogiri::HTML(File.open(File.expand_path('../html/proxies.html', __FILE__)))
  end

  it "puts the proxies on the database" do
    Nokogiri::HTML::Document.should_receive(:parse).and_return(@proxies_doc)
    ProxyWorker.new.perform
    proxies = Proxy.all.map {|p| [p.ip, p.port]}
    proxies =~ proxy_list_test
  end

  it "sets the n proxies ids to [0,n]" do
    Nokogiri::HTML::Document.should_receive(:parse).and_return(@proxies_doc)
    ProxyWorker.new.perform
    proxies = Proxy.all
    proxies.first.id.should == 1
    proxies.last.id.should == proxies.length
  end

  def proxy_list_test
    [["88.150.189.75", "1234"], ["213.186.122.123", "3128"], ["94.228.204.10", "8080"], ["212.175.88.2", "8080"], ["94.228.205.41", "8080"], ["91.230.44.211", "8888"], ["91.189.244.154", "3128"], ["68.180.206.90", "80"], ["192.241.193.142", "3128"], ["187.95.117.80", "3128"], ["74.221.221.64", "7808"], ["118.99.80.108", "80"], ["91.203.69.41", "8080"], ["81.198.230.182", "8080"], ["68.180.211.215", "80"], ["118.99.122.16", "8080"], ["86.111.144.194", "3128"], ["186.46.59.90", "80"], ["46.4.128.33", "443"], ["115.249.100.2", "3128"]]
  end
end
