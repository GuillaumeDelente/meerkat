# spec/models/proxy.rb
require 'spec_helper'

describe Proxy do
  it "has a valid factory" do
    FactoryGirl.create(:proxy).should be_valid
  end

  it "fails validation with no ip_address" do
    FactoryGirl.build(:proxy, :ip => "").should_not be_valid
    FactoryGirl.build(:proxy, :ip => nil).should_not be_valid
  end

  it "fails validation with an incorrect ip_address" do
    FactoryGirl.build(:proxy, :ip => "1.2.180").should_not be_valid
    FactoryGirl.build(:proxy, :ip => "plop").should_not be_valid
  end

  it "fails validation with no port" do
    FactoryGirl.build(:proxy, :port => nil).should_not be_valid
  end

  it "fails validation with an incorrect port" do
    FactoryGirl.build(:proxy, :port => "port").should_not be_valid
  end

  it "returns a valid proxy address" do
    uri = URI.parse(FactoryGirl.build(:proxy).address)
    uri.scheme.should_not be_nil
    uri.host.should_not be_nil
    uri.port.should_not be_nil
  end
end
