# spec/models/proxy.rb
require 'spec_helper'

describe Proxy do
  it "has a valid factory" do
    FactoryGirl.create(:proxy).should be_valid
  end
end
