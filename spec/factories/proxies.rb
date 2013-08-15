# spec/factories/proxies.rb
require 'ffaker'

FactoryGirl.define do
  factory :proxy do |f|
    f.ip { Faker::Internet.ip_v4_address }
    f.port { rand(1..65535) }
  end
end
