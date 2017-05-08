require_relative './node.rb'
require_relative './tag.rb'



module Taskpaper
  class ItemNode < Node
    # ItemNode objects represent "Task" items.
    # Tasks are different from other nodes in that they can contain
    # tags. Tags are attributes on the task.

    def initialize(attrs = { })
      super(attrs)
      self.type = :item
      self.tags = (attrs.has_key?(:tags)) ? attrs[:tags] : [ ]
    end

    attr_reader :tags



    def tags=(arr = [ ])
      if arr.is_a?(Array)
        @tags = arr
      else
        raise TypeError.new("A task's tags must be an array.")
      end
    end



    def to_h(trans = { })
      h = super(trans)
      h[:tags] = self.tags.map { |tag| tag.to_h(trans) }
      return h
    end

  end
end
