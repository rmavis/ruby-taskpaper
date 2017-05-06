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



    def to_yaml(tabs = 0, sep = '  ')
      yaml = [ ]

      spacers = [
        "#{sep * tabs}- ",
        "#{sep * tabs}  "
      ]

      d = self.descriptor
      v = (self.value.nil?) ? 'null' : "\"#{self.value.escape('"')}\""

      yaml.push("#{spacers[0]}type: #{d[0]}")
      yaml.push("#{spacers[1]}#{d[1]}: #{v}")
      yaml.push("#{spacers[1]}tags:")
      self.tags.each { |tag| yaml += tag.to_yaml((tabs + 1), sep) }
      yaml.push("#{spacers[1]}children:")
      self.children.each { |child| yaml += child.to_yaml((tabs + 1), sep) }

      return yaml.join("\n")
    end

  end
end
