require 'geo_phone/phone'
require 'geo_phone/version'
module GeoPhone
  # Your code goes here...
  def self.location(phone)
    Phone.new.location(phone)
  end
end
