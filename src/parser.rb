require_relative './node.rb'
require_relative './item-node.rb'
require_relative './tag.rb'



module Taskpaper
  class Parser

    attr_reader :filename, :nodes

    def initialize(filename = '')
      @filename = nil
      @nodes = nil

      if filename.is_a?(String) || filename.nil?
        @filename = filename
      end
    end



    def nodes=(node = nil)
      if node.nil? || node.is_a?(Node)
        @node = node
      else
        raise TypeError.new("The parser can only set nil or a Node as its `nodes`.")
      end
    end



    def read_lines(filename = self.filename)
      nodes = Taskpaper::Node.new({:type => :doc, :value => filename})
      parents = [nodes]

      # Every line of the file is a Node.
      IO.foreach(filename) do |line|
        line = line.chomp
        node = nil

        tab_count = 0
        current = 0
        while current < line.length
          char = line[current]
          # puts "Checking character '#{char}'"

          if char == "\t"
            tab_count += 1
            current += 1
            next
            # puts "Character is a tab. Tab count: #{tab_count}"

          elsif ((char == '-') &&
                 (line[(current + 1)] == ' ') &&
                 (line.length > (current + 1)))
            # puts "Node is a task/item."
            node = read_item(line[(current + 2), (line.length - current + 2)])
            current = line.length
            next

          else
            node = read_note_or_head(line[current, (line.length - current + 1)])
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



    def read_note_or_head(str = '')
      node = Taskpaper::Node.new
      node.value = str

      if str[(str.length - 1)] == ':'
        node.type = :head
      else
        node.type = :note
      end

      return node
    end



    def read_item(str = '')
      chars = [ ]
      tags = [ ]

      current = 0
      while current < str.length
        char = str[current]

        if char == '@'
          if str[(current - 1)] == ' '
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



    def read_tag(str = '')
      # puts "Reading the next tag from `#{str}`"

      value = [ ]
      param = [ ]

      pushto = value
      open_parens = 0
      current = 0
      while current < str.length
        char = str[current]

        # puts "Checking index `#{current}`: `#{char}`"

        if char == '('
          open_parens += 1
          # puts "Character is an open paren. There are #{open_parens} currently open."
          if open_parens == 1
            # puts "Will start saving characters to `param`."
            pushto = param
          else
            # puts "Pushing character."
            pushto.push(char)
          end
          current += 1
          next

        elsif char == ')'
          open_parens -= 1
          # puts "Character is a close paren. There are #{open_parens} currently open."
          if ((open_parens == 0) &&
              ((str[(current + 1)].nil?) ||
               (str[(current + 1)] == ' ')))
            # puts "And that ends the reading of this tag."
            current += 1
            break
          else
            # puts "Pushing character."
            pushto.push(char)
            current += 1
            next
          end

        elsif char == ' '
          # puts "Character is a space."
          if (open_parens > 0)
            # puts "There are #{open_parens} open parens. Pushing character."
            pushto.push(char)
            current += 1
            next
          else
            # puts "There are no open parens. Ending loop."
            # current += 1
            break
          end

        else
          # puts "Pushing character."
          pushto.push(char)
          current += 1
          next
        end
      end

      tag = nil

      if !value.empty?
        tag = Taskpaper::Tag.new()
        tag.value = value.join
        if !param.empty?
          tag.param = param.join
        end
        # puts "Returning tag with value `#{tag.value}` and param `#{tag.param}` and index #{current}."
      else
        # puts "Returning nil and index #{current}."
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
# # puts node.to_tp
# puts node.to_json
