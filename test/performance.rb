require 'ruby-prof'
require 'geo_phone'
[RubyProf::WALL_TIME, RubyProf::MEMORY, RubyProf::ALLOCATIONS, RubyProf::CPU_TIME].each do |measure|
  RubyProf.measure_mode = measure
  RubyProf.start
  2000.times do
    phone = Random.rand(10000000..100000000)
    GeoPhone.location("138#{phone}")
  end
  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT, :min_percent => 2)
end
