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
      self.type = :item
      self.tags = (attrs.has_key?(:tags)) ? attrs[:tags] : [ ]
    end



    def tags=(arr = nil)
      if arr.nil? || arr.is_a?(Array)
        @tags = arr
      else
        raise TypeError.new("A task's tags must be nil or an array.")
      end
    end



    def to_json
      d = self.descriptor
      v = (self.value.nil?) ? 'nil' : self.value

      c = ''
      self.children.each { |child| c += child.to_json }

      t = [ ]
      self.tags.each { |tag| t.push(tag.to_json) }

      return "{\"type\":\"#{d[0]}\",\"#{d[1]}\":\"#{v}\",\"tags\":[#{t.join(',')}],\"children\":[#{c}]}"
    end

  end
end
