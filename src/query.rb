module Taskpaper
  class Query

    def initialize(q_str = '')
      if (q_str.is_a?(String))
        @string = q_str
      else
        raise ArgumentError.new("Must initialize a Query with a String.")
      end
    end

    attr_reader :string

  end
end
