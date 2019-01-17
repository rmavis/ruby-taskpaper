require_relative './query-clause.rb'
require_relative './utils.rb'



module Taskpaper
  class Query
    # reference: https://guide.taskpaper.com/reference/searches/

    # TODO:
    # shortcuts: https://guide.taskpaper.com/reference/searches/#shortcuts
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
    #   builtin: text, type, level, parent, project, index, uniqueid
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

    # If one part of the query is missing, and that part is optional,
    # then the default will be used.


    def tokenize(str = '')
      puts "STRING: #{str}"
      tokens = [ ]

      n = 0
      m = 0
      while (n < str.length)
        char = str[n]
	    # puts "Checking character '#{char}' (index #{n})"

        if (char == ' ')
	      # puts "Character is space. Skipping."
          n += 1
        elsif (char == '(')
	      # puts "Character is open parens."
          tokens.push({:type => :paren, :val => '('})
          n += 1
        elsif (char == ')')
	      # puts "Character is close parens."
          tokens.push({:type => :paren, :val => ')'})
          n += 1
        elsif ((char == '"') || (char == "'"))
	      # puts "Character is a quote."
          val = str[(n + 1), (str.length - (n + 1))].collect_to(lambda { |c| (c == char) })
          tokens.push({:type => :term, :val => val})
          n += (val.length + 2)  # Skip the quote characters.
	      # puts "Got term: #{tokens}"
        elsif (char == '@')
	      # puts "Character is an attribute marker."
          val = str[(n + 1), (str.length - (n + 1))].collect_to(lambda { |c| ['(', ' '].include?(c) })
          tokens.push({:type => :attribute, :val => val})
          n += (val.length + 1)  # Discard the `@`
	      # puts "Got attribute: #{tokens}"
        else
	      # puts "Character is a character."
          val = str[n, (str.length - n)].collect_to(lambda { |c| [' ', '(', ')', '@'].include?(c) })
          tokens.push({:type => self.get_term_type(val), :val => val})
          n += val.length
	      # puts "Got term: #{tokens}"
        end

        # Just to prevent infinite loops.
        if (n == m)
          puts "BREAKING TOKENIZE WHILE LOOOP"
          break
        else
          m = n
        end
      end

	  puts "TOKENS: #{tokens}"
      return tokens
    end


    def get_term_type(term)
      if (QueryClause::valid_relations.include?(term))
        return :relation
      elsif (QueryClause::valid_logical_operators.include?(term))
        return :logic
      else
        return :term
      end
    end






  end
end


# Taskpaper::Query.new("@todo")
# TOKENS: [{:type=>:attribute, :val=>"todo"}]

# Taskpaper::Query.new("@todo(today)")
# TOKENS: [{:type=>:attribute, :val=>"todo"}, {:type=>:paren, :val=>"("}, {:type=>:term, :val=>"today"}, {:type=>:paren, :val=>")"}]

# Taskpaper::Query.new("this is what")
# TOKENS: [{:type=>:term, :val=>"this"}, {:type=>:term, :val=>"is"}, {:type=>:term, :val=>"what"}]

# Taskpaper::Query.new("this (@is(what))")
# TOKENS: [{:type=>:term, :val=>"this"}, {:type=>:paren, :val=>"("}, {:type=>:attribute, :val=>"is"}, {:type=>:paren, :val=>"("}, {:type=>:term, :val=>"what"}, {:type=>:paren, :val=>")"}, {:type=>:paren, :val=>")"}]

# Taskpaper::Query.new("'this (is' what)")
# TOKENS: [{:type=>:term, :val=>"this (is"}, {:type=>:term, :val=>"what"}, {:type=>:paren, :val=>")"}]

# Taskpaper::Query.new('"th"is (is\' what)')
# TOKENS: [{:type=>:term, :val=>"th"}, {:type=>:term, :val=>"is"}, {:type=>:paren, :val=>"("}, {:type=>:term, :val=>"is'"}, {:type=>:term, :val=>"what"}, {:type=>:paren, :val=>")"}]

Taskpaper::Query.new("@type = project")
Taskpaper::Query.new("@type contains project")
Taskpaper::Query.new("@type not project")
Taskpaper::Query.new("not project")
Taskpaper::Query.new("yum")
