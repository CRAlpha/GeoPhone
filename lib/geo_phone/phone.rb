module GeoPhone
  require 'geo_phone/database'
  class InvalidPhoneError < StandardError
    def initialize(phone)
      @phone = phone
    end

    def message
      "#{@phone}的格式不正确"
    end
  end

  class Phone
    def initialize(phone)
      @phone = phone
      validate
    end

    def get_phone_type(no)
      PHONE_TYPES[no-1]
    end

    def location
      int_phone = @phone[0..6].to_i
      left = 0
      right = Database.instance.index_count
      while left<=right do
        middle = (left + right) / 2
        current_offset =  middle * INDEX_LENGTH
        return if current_offset + Database.instance.index_offset >= Database.instance.file_size
        cur_phone, record_offset, phone_type = Database.instance.index[current_offset..(current_offset+INDEX_LENGTH)].unpack(INDEX_FMT)
        if cur_phone > int_phone
          right = middle - 1
        elsif cur_phone < int_phone
          left = middle + 1
        else
          content = Database.instance.read(record_offset)
          return {
            phone: @phone,
            province: content[0],
            city: content[1],
            zip_code: content[2],
            area_code: content[3],
            phone_type: get_phone_type(phone_type)
          }
        end
      end
    end


    private
    def validate
      raise InvalidPhoneError.new(@phone) unless @phone =~ /\A^(0|86|17951)?(13[0-9]|15[0-9]|17[678]|18[0-9]|14[57])[0-9]{8}\z/i
    end
  end
end
