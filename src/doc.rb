require_relative './utils.rb'
require_relative './node.rb'
require_relative './parser.rb'



module Taskpaper
  class Doc


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
        return Parser::read_lines(self.filename)
      else
        puts "Error: can't read file '#{self.filename}'."
        return nil
      end
    end




    protected


    def can_read?(filename = self.filename)
      return (File.exist?(filename) && File.readable?(filename))
    end


  end

end



doc = Taskpaper::Doc.new('sample.taskpaper')
node = doc.parse
# puts node.to_tp
puts node.to_json
