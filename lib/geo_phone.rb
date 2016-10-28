require 'geo_phone/phone'
require 'geo_phone/version'
module GeoPhone
  # Your code goes here...
  def self.location(phone)
    p = Phone.new()
    p.location(phone)
  end
end
