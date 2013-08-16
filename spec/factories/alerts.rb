# spec/factories/alerts.rb
require 'ffaker'

FactoryGirl.define do
  factory :alert do
    name Faker::Product.product_name
    query do
      uri = URI.parse("http://www.leboncoin.fr/annonces/offres/aquitaine")
      uri.query = URI.encode_www_form("f" => "a", "th" => "1", "q" => name)
      uri.to_s
    end
    active true
    user
  end
end
