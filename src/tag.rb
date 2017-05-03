require_relative './utils.rb'



module Taskpaper
  class Tag

    attr_reader :value, :param

    def initialize(attrs = { })
      def_attrs = {
        :value => nil,
        :param => nil
      }

      if attrs.is_a?(Hash)
        def_attrs.sieve(attrs).each do |key,val|
          public_send("#{key}=", val)
        end
      else
        def_attrs.each do |key,val|
          public_send("#{key}=", val)
        end
      end
    end



    def value=(val = nil)
      if val.nil? || val.is_a?(String)
        @value = val
      else
        raise TypeError.new("A node's value must be a string or nil.")
      end
    end



    def param=(val = nil)
      if val.nil? || val.is_a?(String)
        @param = val
      else
        raise TypeError.new("A node's param must be a string or nil.")
      end
    end



    def to_json
      return "{\"value\":\"#{self.value}\",\"param\":\"#{self.param}\"}"
    end

  end
end
