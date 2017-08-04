module Taskpaper
  class QueryClause

    def default_q
      {
        # The attribute is the thing that will be searched. There
        # are builtin attributes: :type, :text, :level, :parent,
        #   :project, :index, :uniqueid
        # But the user can define and query their own attributes.
        # `@done` is an attribute with no associated value.
        # `@do(today)` specifies an attribute named `do` with a
        # value of `today`.
        # Default: :text
        :attr => :text,
        # The relation is the form/mode of comparison. Legal forms:
        #   =, !=, >, <, <=, >=, contains, (begins|ends)with, matches
        # The `matches` relation converts the query term to a regex.
        # Default: contains (case-insensitive)
        :rel => :contains,
        # And this is the query term.
        :val => nil,
        # The logical operator. Legal values: and, or, not.
        # Default: nil
        :op => nil
      }
    end

    # The `attr` indicates the value of the Node check against.
    # The `rel` could contain a symbol that maps to a method name.
    # Each of those could receive the same parameters (two strings)
    # and return a bool.
    # And the `val` will contain the given query.
    # A query can contain an arbitrary number of such groupings.
    # Query phrases can be combined with logical operators.
    # Query phrases can be grouped with parentheses.


  end
end
