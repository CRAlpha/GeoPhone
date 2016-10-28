require 'stringio'
module GeoPhone
  HEAD_FMT = 'A4V'
  HEAD_LENGTH = 8
  RECORD_FMT = 'VVC'
  RECORD_LENGTH = 9
  DB_PATH = File.expand_path '../../data/phone.dat', __FILE__
  PHONE_TYPES = %w(移动 联通 电信 移动虚拟运营商 联通虚拟运营商 电信虚拟运营商)

  class InvalidPhoneError < StandardError
    def initialize(phone)
      @phone = phone
    end

    def message
      "#{@phone}的格式不正确"
    end
  end

  class Phone
    def initialize
      @version, @records_offset = IO.read(DB_PATH, 8).unpack(HEAD_FMT)
      @file_size = File.size(DB_PATH)
      @records_count = (@file_size - @records_offset) / RECORD_LENGTH
    end

    def get_phone_type(no)
      PHONE_TYPES[no+1]
    end

    def location(phone)
      validate(phone)
      int_phone = phone[0..6].to_i
      left = 0
      right = @records_count
      File.open(DB_PATH, 'rb') do |file|
        while left<=right do
          middle = (left + right) / 2
          current_offset = @records_offset + middle * RECORD_LENGTH
          return if current_offset >= @file_size
          file.seek(current_offset)
          cur_phone, record_offset, phone_type = file.read(RECORD_LENGTH).unpack(RECORD_FMT)
          if cur_phone > int_phone
            right = middle - 1
          elsif cur_phone < int_phone
            left = middle + 1
          else
            content = get_record_content(file, record_offset)
            return {
              phone: phone,
              province: content[0],
              city: content[1],
              zip_code: content[2],
              area_code: content[3],
              phone_type: get_phone_type(phone_type)
            }
          end
        end
      end
    end

    def get_record_content(file, start_offset)
      file.seek(start_offset)
      content = ''
      loop do
        temp = file.read(1)
        break if temp == "\x00"
        content << temp
      end
      content.split('|').map { |c| c.force_encoding('UTF-8') }
    end

    private
    def validate(phone)
      raise InvalidPhoneError.new(phone) unless phone =~ /\A^(0|86|17951)?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}\z/i
    end
  end
end
