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



    def to_h(trans = { })
      v = (trans.has_key?(:value)) ? trans[:value].call(self.value) : self.value
      p = (trans.has_key?(:value)) ? trans[:value].call(self.param) : self.param
      # p = (trans.has_key?(:param)) ? trans[:param].call(self.param) : self.param

      return {
        :value => v,
        :param => p
      }
    end



    def to_yaml(tabs = 0, sep = '  ')
      yaml = [ ]

      v = (self.value.nil?) ? 'null' : "\"#{self.value.escape('"')}\""
      p = (self.param.nil?) ? 'null' : "\"#{self.param.escape('"')}\""

      yaml.push("#{sep * tabs}- value: #{v}")
      yaml.push("#{sep * tabs}  param: #{p}")

      return yaml.join("\n")
    end

  end
end
