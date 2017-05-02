module Taskpaper
  class Parser

    def self.read_lines(filename = '')
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
