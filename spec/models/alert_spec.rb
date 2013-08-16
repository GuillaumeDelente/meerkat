# spec/models/alert_spec.rb
require 'spec_helper'

describe Alert do

  it "has a valid factory" do
    FactoryGirl.create(:alert).should be_valid
  end

  it "fails validation without a name" do
    FactoryGirl.build(:alert, :name => '').should_not be_valid
  end

  it "fails validation without a user" do
    FactoryGirl.build(:alert, :user => nil).should_not be_valid
  end

  it "fails validation without a query" do
    FactoryGirl.build(:alert, :query => '').should_not be_valid
  end

end
