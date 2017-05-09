require_relative './node.rb'
require_relative './item-node.rb'
require_relative './tag.rb'



module Taskpaper
  class Parser



    def initialize(filename = '')
      @filename = nil
      @nodes = nil

      if filename.is_a?(String) || filename.nil?
        @filename = filename
      end
    end

    attr_reader :filename, :nodes



    def nodes=(node = nil)
      if node.nil? || node.is_a?(Node)
        @node = node
      else
        raise TypeError.new("The parser can only set nil or a Node as its `nodes`.")
      end
    end



    def read_lines(filename = self.filename)
      nodes = Taskpaper::Node.new({:type => :doc, :value => File.basename(filename)})
      parents = [nodes]

      # Every line of the file is a Node.
      IO.foreach(filename) do |line|
        line = line.chomp
        node = nil

        tab_count = 0
        current = 0
        while current < line.length
          char = line[current]

          # The only meaningful characters are:
          # - tabs, which designate hierarchy
          # - dash + space, which indicates a task/item
          # - colon, when it occurs at the end of a line,
          #   to designate a project/head

          if (char == "\t")
            tab_count += 1
            current += 1
            next

          elsif ((char == '-') &&
                 (line[(current + 1)] == ' ') &&
                 (line.length > (current + 1)))
            # Skip the dash and space characters.
            node = read_item(line[(current + 2), (line.length - current + 2)])
            current = line.length
            next

          else
            node = read_head_or_note(line[current, (line.length - current + 1)])
            current = line.length
            next
          end
        end

        parents[(tab_count + 1)] = (node.nil?) ? Node.new({:type => :note}) : node
        node.parent = parents[tab_count]
        node.parent.children.push(node)
      end

      self.nodes = nodes
      return nodes
    end



    # Pass this a string that should be a `head` or a `note` node.
    # If it's a `head`, the trailing colon will be removed from the
    # node's `value`.
    def read_head_or_note(str = '')
      node = Taskpaper::Node.new

      if (str[(str.length - 1)] == ':')
        node.type = :head
        node.value = str.chop
      else
        node.type = :note
        node.value = str
      end

      return node
    end



    # Pass this a string that should be an `item` node. Do not
    # include the leading dash and space characters. If tags are
    # present, the node's `tags` array will be filled but they will
    # not be removed from its `value`. This is because tags could
    # have some semantic value and occur anywhere in the string.
    def read_item(str = '')
      chars = [ ]
      tags = [ ]

      current = 0
      while current < str.length
        char = str[current]

        # Tags are indicated by a leading `@`.
        if (char == '@')
          # So it's only a tag if the preceding character is a space.
          if (str[(current - 1)] == ' ')
            _t = read_tag(str[(current + 1), (str.length - current + 1)])
            adv = (_t[:length] + 1)  # The 1 accommodates the '@'
            # puts "Pushing `#{str[current, adv]}`"
            chars.push(str[current, adv])
            tags.push(_t[:tag]) if _t[:tag].is_a?(Taskpaper::Tag)
            current += adv
            # puts "Tag reader advanced current position: `#{str[current, (str.length - current)]}`"
          else
            chars.push(char)
            current += 1
          end
        else
          chars.push(char)
          current += 1
        end
      end

      node = Taskpaper::ItemNode.new({:value => chars.join})
      node.tags = tags if !tags.empty?

      return node
    end



    # Pass this a string that should be a tag. Do not include the
    # leading `@`. Tags can include parameters, which are wrapped in
    # parentheses. Tags can be nested but, for our purposes, are not
    # handled in that way. This returns a hash containing two keys:
    # - :tag, being a Tag node
    # - :length, being the length of the substring read from the
    #   parameter, which is useful for advancing the read position
    #   in `read_line`
    def read_tag(str = '')
      value = [ ]
      param = [ ]

      pushto = value
      open_parens = 0
      current = 0
      while current < str.length
        char = str[current]

        if (char == '(')
          open_parens += 1
          if open_parens == 1
            pushto = param
          else
            pushto.push(char)
          end

        elsif (char == ')')
          open_parens -= 1
          # If it's the final closing paren, that ends the tag.
          if ((open_parens == 0) &&
              ((str[(current + 1)].nil?) ||
               (str[(current + 1)] == ' ')))
            # Include the final character in the length.
            current += 1
            break
          else
            pushto.push(char)
          end

        elsif (char == ' ')
          # A space can either end the tag or be part of the param.
          if (open_parens > 0)
            pushto.push(char)
          else
            break
          end

        else
          pushto.push(char)
        end

        current += 1
      end

      tag = nil

      if !value.empty?
        tag = Taskpaper::Tag.new({:value => value.join})
        tag.param = param.join if !param.empty?
      end

      return {
        :tag => tag,
        :length => current
      }
    end

  end
end



# p = Taskpaper::Parser.new('../sample.taskpaper')
# node = p.read_lines
# puts node.to_tp
# puts node.to_json
# puts node.to_yaml
