require_relative './node.rb'
require_relative './tag.rb'



module Taskpaper
  class ItemNode < Node
    # ItemNode objects represent "Task" items.
    # Tasks are different from other nodes in that they can contain
    # tags. Tags are attributes on the task.

    attr_reader :tags

    def initialize(attrs = { })
      super(attrs)
      self.tags = (attrs.has_key?(:tags)) ? attrs[:tags] : [ ]
    end



    def tags=(arr = nil)
      if arr.nil? || arr.is_a?(Array)
        @tags = arr
      else
        raise TypeError.new("A task's tags must be nil or an array.")
      end
    end

  end
end
