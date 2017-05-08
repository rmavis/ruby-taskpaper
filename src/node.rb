require_relative './utils.rb'



module Taskpaper
  # Every line of a file is a node.
  # The document itself is a node.
  # There is exactly one document per file.
  # Properties that define a node include:
  # - its type (:doc, :head, :item, :note)
  # - its value (the text; blank lines == blank notes)
  # - its parent node (:doc nodes have a `nil` parent)
  # - its children (an array of nodes)
  class Node

    def self.types
      [
        :doc,
        :head,
        :item,
        :note
      ]
    end



    def initialize(attrs = { })
      def_attrs = {
        :type => nil,
        :value => nil,
        :parent => nil,
        :children => [ ]
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

    attr_reader :type, :value, :parent, :children



    def type=(val = nil)
      if val.nil?
        @type = val
      elsif val.is_a?(Symbol)
        if Node.types.include?(val)
          @type = val
        else
          raise ArgumentError.new("A node's type must be one of these: #{Node.types.to_s}")
        end
      else
        raise TypeError.new("A node's value must be nil or a known symbol.")
      end
    end



    def value=(val = nil)
      if (val.nil? || val.is_a?(String))
        @value = val
      else
        raise TypeError.new("A node's value must be a string or nil.")
      end
    end



    def parent=(node = nil)
      if (node.nil? || node.is_a?(Node))
        @parent = node
      else
        raise TypeError.new("A node's parent must be nil or a node.")
      end
    end



    def children=(arr = [ ])
      if arr.is_a?(Array)
        @children = arr
      else
        raise TypeError.new("A node's `children` must be an array.")
      end
    end



    def descriptor
      case self.type
      when :doc
        ["document", "name"]
      when :head
        ["project", "value"]
      when :item
        ["task", "value"]
      when :note
        ["note", "value"]
      else
        ["nil", "unknown"]
      end
    end



    #
    # These four functions might be pointless.
    #

    # def info_arr
    #   t = (self.type.nil?) ? 'nil' : self.type.to_s
    #   v = (self.value.nil?) ? 'nil' : self.value
    #   return [t, v]
    # end

    # def info_short
    #   a = self.info_arr
    #   return "#{a[0]}: #{a[1]}"
    # end

    # def info_long
    #   a = self.info_arr
    #   return "Type: #{a[0]}\nValue: #{a[1]}"
    # end

    # def describe
    #   p = (self.parent.is_a?(Node)) ? self.parent.info_short : 'nil'
    #   return "#{self.info_long}\nParent: #{p}\nNumber of children: #{self.children.length}"
    # end



    # def to_h(trans = { })
    #   d = self.descriptor

    #   t = (trans.has_key?(:type)) ? trans[:type].call(self.type) : d[0]
    #   v = (trans.has_key?(:value)) ? trans[:value].call(self.value) : self.value

    #   return {
    #     :type => t,
    #     d[1].to_sym => v,
    #     :children => self.children.map { |child| child.to_h(trans) }
    #   }
    # end



    def to_json
      require_relative './printer-json.rb'
      p = JsonPrinter.new(self)
      return p.print_node
    end



    def to_yaml(tabs = 0, sep = '  ')
      require_relative './printer-yaml.rb'
      p = YamlPrinter.new(self)
      return p.print_node
    end



    def to_tp(tabs = -1, sep = "\t")
      tp = [ ]

      if (self.type != :doc)
        if (self.type == :head)
          tp.push("#{(sep * tabs)}#{self.value}:")
        elsif (self.type == :item)
          tp.push("#{(sep * tabs)}- #{self.value}")
        else
          tp.push("#{(sep * tabs)}#{self.value}")
        end
      end

      if (self.children.length > 0)
        self.children.each { |child| tp.push(child.to_tp((tabs + 1), sep)) }
      end

      return tp.join("\n")
    end


  end
end
