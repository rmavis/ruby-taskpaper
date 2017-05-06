require_relative './printer.rb'



# TODO
# - YAML seems to have a problem with slashes, even when they're wrapped in quotes.

module Taskpaper
  class YamlPrinter < Printer

    def print_node(node = self.node)
      return self.h_to_a(self.to_h(node)).join("\n")
    end



    def h_to_a(node = { }, tabs = 0, sep = '  ')
      strs = [ ]

      spacers = (tabs == 0) ? ['', ''] : ["#{sep * tabs}- ", "#{sep * (tabs + 1)}"]

      i = 0
      node.each do |key,val|
        if val.is_a?(String)
          strs.push("#{spacers[i]}#{key}: \"#{val.escape('"')}\"")
        elsif val.is_a?(Array)
          strs.push("#{spacers[i]}#{key}:")
          strs += val.map { |v| self.h_to_a(v, (tabs + 1), sep) }
        elsif val.nil?
          strs.push("#{spacers[i]}#{key}: null")
        else
          puts "WTF: `#{key}` => `#{val}`"
          # Throw an exception?  @TODO
        end

        if i == 0
          i = 1
          tabs += 1 if (tabs > 0)
        end
      end

      return strs
    end



  end
end
