require_relative './printer.rb'



module Taskpaper
  class JsonPrinter < Printer

    def print_node(node = self.node)
      return self.print_hash(self.to_h(node))
    end



    def print_hash(node = { })
      strs = [ ]

      node.each do |key,val|
        if val.is_a?(String)
          strs.push("\"#{key.to_s}\":\"#{val.escape('"')}\"")
        elsif val.is_a?(Array)
          strs.push("\"#{key.to_s}\":[#{(val.map { |v| self.print_hash(v) }).join(',')}]")
        elsif val.nil?
          strs.push("\"#{key.to_s}\":null")
        else
          puts "WTF: `#{key}` => `#{val}`"
          # Throw an exception?  @TODO
        end
      end

      return "{#{strs.join(',')}}"
    end

  end
end
