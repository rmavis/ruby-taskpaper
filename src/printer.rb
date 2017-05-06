require_relative './node.rb'
require_relative './item-node.rb'
require_relative './tag.rb'



module Taskpaper
  class Printer

    def initialize(node = nil)
      public_send("node=", node)
    end

    attr_reader :node



    def node=(val)
      if (val.nil? || val.is_a?(Node))
        @node = val
      else
        raise TypeError.new("The JSON Printer can only work with Nodes.")
      end
    end



    def to_h(node = self.node)
      if node.is_a?(Tag)
        return self.tag_to_h(node)
      elsif node.is_a?(ItemNode)
        return self.item_to_h(node)
      else
        return self.node_to_h(node)
      end
    end



    def node_to_h(node)
      d = node.descriptor

      return {
        :type => d[0],
        d[1].to_sym => node.value,
        :children => node.children.map { |child| self.to_h(child) }
      }
    end



    def item_to_h(node)
      n = self.node_to_h(node)
      n[:tags] = node.tags.map { |tag| self.to_h(tag) }
      return n
    end



    def tag_to_h(tag)
      return {
        :value => tag.value,
        :param => tag.param
      }
    end


  end
end
