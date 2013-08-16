# spec/workers/alert_worker_spec.rb
require 'spec_helper'

describe AlertWorker do
  before(:all) do
    @alertes_doc = Nokogiri::HTML(File.open(File.expand_path('../html/alertes.html', __FILE__)))
  end

  it "retrieves the last current ad"
end
