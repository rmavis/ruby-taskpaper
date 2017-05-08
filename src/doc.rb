require_relative './parser.rb'



module Taskpaper
  class Doc


    def initialize(filename = nil)
      if (filename.nil? || filename.is_a?(String))
        @filename = filename
      else
        raise ArgumentError.new("Must initialize a new Doc with a string (the filename) or `nil` (default).")
      end
    end

    attr_accessor :filename



    def parse(filename = self.filename)
      if self.can_read?(filename)
        return Parser::read_lines(filename)
      else
        raise RuntimeError.new("Unable to parse '#{filename}': can't read file.")
      end
    end




    protected


    def can_read?(filename = self.filename)
      return (File.exist?(filename) && File.readable?(filename))
    end


  end

end
