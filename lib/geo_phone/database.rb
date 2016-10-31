require 'singleton'
module GeoPhone
  DB_PATH = File.expand_path '../../data/phone.dat', __FILE__
  HEAD_FMT = 'A4V'
  HEAD_LENGTH = 8
  INDEX_FMT = 'VVC'
  INDEX_LENGTH = 9
  PHONE_TYPES = %w(移动 联通 电信 移动虚拟运营商 联通虚拟运营商 电信虚拟运营商)

  class Database
    include Singleton
    attr_reader :index_count
    attr_reader :index
    attr_reader :index_offset
    attr_reader :file_size

    def initialize
      load_index
      super
    end

    def read(start_offset)
      content = ''
      File.open(DB_PATH) do |file|
        file.seek(start_offset)
        loop do
          temp = file.read(1)
          break if temp == "\x00"
          content << temp
        end
      end
      content.split('|').map { |c| c.encode('UTF-8','UTF-8') }
    end

    private
    def load_index
      @file_size = File.size(DB_PATH)
      File.open(DB_PATH) do |file|
        @version, @index_offset = file.read(8).unpack(HEAD_FMT)
        file.seek(@index_offset)
        @index = file.read(@file_size - @index_offset)
        @index_count = (@file_size - @index_offset) / INDEX_LENGTH
      end
    end
  end
end

