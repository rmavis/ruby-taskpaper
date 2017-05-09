require_relative './parser.rb'



module Taskpaper
  class Doc


    def initialize(filename = '')
      @filename = nil
      @nodes = nil

      self.filename = filename
    end

    attr_reader :filename, :nodes



    def filename=(val)
      if val.is_a?(String)
        @filename = val
      else
        raise ArgumentError.new("A Doc's `filename` must be a string.")
      end
    end



    def nodes=(val)
      if val.is_a?(Node)
        @nodes = val
      else
        raise ArgumentError.new("A Doc's `nodes` must be a Node.")
      end
    end



    def parse(filename = self.filename)
      if self.can_read?(filename)
        p = Parser.new(filename)
        return p.read_lines(filename)
      else
        raise RuntimeError.new("Unable to parse '#{filename}': can't read file.")
      end
    end



    def parse!(filename = self.filename)
      self.nodes = self.parse(filename)
    end




    protected


    def can_read?(filename = self.filename)
      return (File.exist?(filename) && File.readable?(filename))
    end


  end

end
