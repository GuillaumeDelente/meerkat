# spec/models/proxy.rb
require 'spec_helper'

describe Proxy do
  it "has a valid factory" do
    FactoryGirl.create(:proxy).should be_valid
  end

  it "fails validation with no ip_address" do
    FactoryGirl.build(:proxy, :ip_address => "").should_not be_valid
    FactoryGirl.build(:proxy, :ip_address => nil).should_not be_valid
  end

  it "fails validation with an incorrect ip_address" do
    FactoryGirl.build(:proxy, :ip_address => "http://1:80").should_not be_valid
    FactoryGirl.build(:proxy, :ip_address => "plop").should_not be_valid
  end
end
