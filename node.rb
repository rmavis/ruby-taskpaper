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



    attr_reader :type, :value, :parent, :children

    def initialize(attrs = { })
      _attrs = {
        :type => nil,
        :value => nil,
        :parent => nil,
        :children => [ ]
      }

      _attrs.each do |key,val|
        public_send("#{key}=", val)
      end

      if attrs.is_a?(Hash)
        attrs.each do |key,val|
          if _attrs.has_key?(key)
            public_send("#{key}=", val)
          end
        end
      end
    end



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
      if val.nil? || val.is_a?(String)
        @value = val
      else
        raise TypeError.new("A node's value must be a string or nil.")
      end
    end



    def parent=(node = nil)
      if is_relation_valid?(node)
        @parent = node
      else
        raise TypeError.new("A node's parent must be nil or a node.")
      end
    end



    def children=(arr = nil)
      if arr.nil? || arr.is_a?(Array)
        @children = arr
      else
        raise TypeError.new("A node's children must be nil or an array.")
      end
    end



    def descriptor
      case self.type
      when :doc
        ["document", "name"]
      when :head
        ["project", "title"]
      when :item
        ["task", "value"]
      when :note
        ["note", "value"]
      else
        ["nil", "unknown"]
      end
    end



    def info_arr
      t = (self.type.nil?) ? 'nil' : self.type.to_s
      v = (self.value.nil?) ? 'nil' : self.value
      return [t, v]
    end



    def info_short
      a = self.info_arr
      return "#{a[0]}: #{a[1]}"
    end



    def info_long
      a = self.info_arr
      return "Type: #{a[0]}\nValue: #{a[1]}"
    end



    def describe
      p = (self.parent.is_a?(Node)) ? self.parent.info_short : 'nil'
      return "#{self.info_long}\nParent: #{p}\nNumber of children: #{self.children.length}"
    end



    def to_tp(tabs = -1)
      tp = [ ]

      if ((self.type != :doc) && (self.value.is_a?(String)))
        tp.push("#{("\t" * tabs)}#{self.value}")
      end

      if self.children.length > 0
        self.children.each { |child| tp.push(child.to_tp((tabs + 1))) }
      end

      return tp.join("\n")
    end



    def to_json
      d = self.descriptor
      v = (self.value.nil?) ? 'nil' : self.value

      c = ''
      self.children.each { |child| c += child.to_json }

      return "{\"type\":\"#{d[0]}\",\"#{d[1]}\":\"#{v}\",\"children\":[#{c}]}"
    end




    private


    def is_relation_valid?(node = nil)
      return (node.nil? || node.is_a?(Taskpaper::Node))
    end

  end
end
