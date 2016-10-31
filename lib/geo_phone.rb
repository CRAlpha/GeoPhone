module GeoPhone
  require 'geo_phone/phone'
  require 'geo_phone/version'
  # Your code goes here...
  def self.location(phone)
    Phone.new(phone).location
  end
end
