module Taskpaper
  class Doc

    require_relative('node.rb')


    def initialize(filename = nil)
      if filename.nil? || filename.is_a?(String)
        @filename = filename
      else
        raise ArgumentError.new("Must initialize a new Taskpaper::Doc with a string (the filename) or `nil` (default).")
      end
    end

    attr_accessor :filename



    def parse
      if self.can_read?(self.filename)
        return read_lines(self.filename)
      else
        puts "Error: can't read file '#{self.filename}'."
        return nil
      end
    end




    protected


    def can_read?(filename = self.filename)
      return (File.exist?(filename) && File.readable?(filename))
    end



    def read_lines(filename = self.filename)
      tree = Taskpaper::Node.new({:type => :doc, :value => filename})

      parents = [tree]

      IO.foreach(filename) do |line|
        line = line.chomp

        node = Taskpaper::Node.new({:type => :note})

        should_capture = false
        tab_count = 0
        chars = [ ]

        for o in 0...(line.length) do
          char = line[o]
          # puts "Checking character '#{char}'"

          if char == "\t"
            tab_count += 1
            # puts "Character is a tab. Tab count: #{tab_count}"

          elsif char == '-'
            if chars.empty?
              # puts "Node is a task."
              node.type = :item
            end
            should_capture = true

          elsif char == ':'
            # puts "Character is a colon."
            # puts "#{o} vs #{(line.length - 1)}"

            if (o == (line.length - 1))
              # puts "Node is a project."
              node.type = :head
            else
              # puts "Node is not a project. Should capture future characters."
              should_capture = true
            end

          else
            # puts "Should capture future characters."
            should_capture = true
          end

          if should_capture
            chars.push(char)
            # puts "Capturing. Characters: #{chars.to_s}"
          end
        end

        parents[(tab_count + 1)] = node
        node.parent = parents[tab_count]
        node.parent.children.push(node)

        node.value = chars.join
      end

      return tree
    end

  end

end



doc = Taskpaper::Doc.new('sample.taskpaper')
node = doc.parse
# puts node.to_tp
puts node.to_json
