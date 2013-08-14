# spec/factories/proxies.rb
require 'ffaker'

FactoryGirl.define do
  factory :proxy do |f|
    f.ip_address { "http://#{Faker::Internet.ip_v4_address}:#{rand(0..65535)}" }
  end
end
