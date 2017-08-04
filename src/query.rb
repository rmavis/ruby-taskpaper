require_relative './query-clause.rb'



module Taskpaper
  class Query
    # reference: https://guide.taskpaper.com/reference/searches/

    # TODO:
    # relation modifiers 
    # item path queries

    def initialize(q_str = '')
      if (q_str.is_a?(String))
        tokens = self.tokenize(q_str)
      else
        raise ArgumentError.new("Must initialize a Query with a String.")
      end
    end

    attr_reader :string

    # All queries take the form:
    # [logical operator] attribute [relation modifier] relation term
    # - logical operator
    #   legal: and, or, not
    #   optional
    #   default: nil
    # - attribute, which is the content to search
    #   builtin: type, text, level, parent, project, index, uniqueid
    #   required
    #   default: text
    # - relation modifier
    #   valid: @TODO
    #   optional
    #   default: nil
    # - relation, which is the comparision operation
    #   legal: =, !=, >, <, >=, <=, contains, (begins|ends)with, matches
    #   required
    #   default: contains (case-insensitive)
    # - value: the string to check for
    #   required

    # Examples:
    # - foo
    #   : @text contains foo
    # - @type proj
    #   : @type contains proj
    # - @type = project
    #   : type = project
    # - @priority > 1
    #   : text contains @priority(.+) and $1 > 1


    def tokenize(str = '')
      tokens = [ ]

      n = 0
      o = 0
      p = 0
      x = 10
      while (n < str.length)
        char = str[n]
	    puts "Checking character '#{char}' (index #{n})"

        if (char == ' ')
	      # puts "Character is space. Skipping."
          n += 1
        elsif (char == '(')
	      # puts "Character is open parens."
          tokens.push({:type => :grouper, :val => '('})
          n += 1
        elsif (char == ')')
	      # puts "Character is close parens."
          tokens.push({:type => :grouper, :val => ')'})
          n += 1
        elsif ((char == '"') || (char == "'"))
	      # puts "Character is a quote."
          n += 1  # Discard the quote.
          t = self.up_to_char(str[n, (str.length - n)], char)
          tokens.push({:type => :term, :val => t[:value]})
	      # puts "Got term: #{tokens}"
          n += (t[:index] + 1)  # Skip the closing quote.
        elsif (char == '@')
	      # puts "Character is an attribute marker."
          n += 1  # Discard the `@`.
          t = self.up_to_char(str[n, (str.length - n)], ['(', ' '])
          tokens.push({:type => :attribute, :val => t[:value]})
	      # puts "Got attribute: #{tokens}"
          n += t[:index]
        else
	      # puts "Character is a character."
          t = self.up_to_char(str[n, (str.length - n)], [' ', '(', ')', '@'])
          tokens.push({:type => :term, :val => t[:value]})
	      # puts "Got term: #{tokens}"
          n += t[:index]
        end

        # Just to prevent infinite loops.
        if (o == n)
          p += 1
          if (p >= x)
            puts "BREAKING TOKENIZE WHILE LOOOP"
            break
          end
        else
          o = n
        end
      end

	  puts "TOKENS: #{tokens}"
      return tokens
    end



    # `char` can be an array or a string.
    def up_to_char(str, stop = ' ')
      parts = [ ]
      n = 0

      if stop.is_a?(Array)
        while (n < str.length)
          char = str[n]
          if (stop.include?(char))
            break
          else
            parts.push(char)
            n += 1
          end
        end

      elsif stop.is_a?(String)
        while (n < str.length)
          char = str[n]
          if (stop == char)
            break
          else
            parts.push(char)
            n += 1
          end
        end

      else
        puts "NO STOP CHARACTER GIVEN"
      end

      return {
        :value => parts.join,
        :index => n
      }
    end



    # Valid attribute forms:
    # @name
    # @name(value)
    # @name relation value
    # def get_attribute_token(str = '')
    #   t = {
    #     :token => nil,
    #     :index => 0
    #   }

    #   return t
    # end


  end
end


# Taskpaper::Query.new("@todo")
# TOKENS: [{:type=>:attribute, :val=>"todo"}]

# Taskpaper::Query.new("@todo(today)")
# TOKENS: [{:type=>:attribute, :val=>"todo"}, {:type=>:grouper, :val=>"("}, {:type=>:term, :val=>"today"}, {:type=>:grouper, :val=>")"}]

# Taskpaper::Query.new("this is what")
# TOKENS: [{:type=>:term, :val=>"this"}, {:type=>:term, :val=>"is"}, {:type=>:term, :val=>"what"}]

# Taskpaper::Query.new("this (@is(what))")
# TOKENS: [{:type=>:term, :val=>"this"}, {:type=>:grouper, :val=>"("}, {:type=>:attribute, :val=>"is"}, {:type=>:grouper, :val=>"("}, {:type=>:term, :val=>"what"}, {:type=>:grouper, :val=>")"}, {:type=>:grouper, :val=>")"}]

# Taskpaper::Query.new("'this (is' what)")
# TOKENS: [{:type=>:term, :val=>"this (is"}, {:type=>:term, :val=>"what"}, {:type=>:grouper, :val=>")"}]

# Taskpaper::Query.new('"th"is (is\' what)')
# TOKENS: [{:type=>:term, :val=>"th"}, {:type=>:term, :val=>"is"}, {:type=>:grouper, :val=>"("}, {:type=>:term, :val=>"is'"}, {:type=>:term, :val=>"what"}, {:type=>:grouper, :val=>")"}]
