#!/usr/bin/env ruby

require_relative './src/doc.rb'
require_relative './src/query.rb'



module Taskpaper
  class Session

    def initialize(args = [ ])
      if ((args.is_a?(Array)) && (args.length > 0))
        self.act_on_args(self.parse_args(args))
      else
        # Print a help message.
        puts "Someday this will be a helpful message."
      end
    end



    # -q, --query: filter doc via given query
    # -j, --json: print doc as json
    # -y, --yaml: print doc as yaml
    # Essential parts:
    # - file to read
    # - action to take
    #   - parse, transform, print
    #   - parse, search
    # - modification of action
    # All actions are the same: parse the file, print the output.
    # But the added parameter of the query string will filter the
    # output.
    # The output format is required for every action. The default
    # can be JSON.
    # The input filename is required for every action. If none is
    # given, then an error will be thrown.
    # The query string is optional.
    def parse_args(args = [ ])
      ret = {
        :infile => nil,
        :printer => :to_json,
        :query => nil
      }

      n = 0
      while (n < args.length)
        arg = args[n]

        if (arg[0] == '-')
          if (arg[1] == '-')  # Long-form args.
            check = self.check_long_arg(arg[2, (arg.length - 2)].downcase)
          else  # Short-form args.
            check = self.check_short_arg(arg[1, (arg.length - 1)].downcase)
          end

          if (check.is_a?(Hash))
            if (check.has_key?(:query))
              if (check[:query] == :next)
                # For now, just collect the rest of the args.  @TODO
                ret[:query] = Query.new(args.slice((n + 1), (args.length - (n + 1))).join(' '))
                n = args.length
              else
                ret = ret.merge(check)
              end
            else
              ret = ret.merge(check)
            end
          else
            raise RuntimeError.new("Weird return from argument scan: `#{check.to_s}`.")
          end
        else
          ret[:infile] = arg
        end

        n += 1
      end

      return ret
    end


    # Would it be better to just return the actions to take?


    def check_long_arg(arg = '')
      # For `--json`
      if ((arg == 'json') || (arg == 'yaml'))
        return {:printer => "to_#{arg}".to_sym}
      # For `--out=json`
      elsif (m = arg.match(/out=(json|yaml)/))
        return {:printer => "to_#{m[1]}".to_sym}
      # For `--query="query string"`
      elsif (arg[0, 5] == 'query')
        if (arg[5] == '=')
          return {:query => Query.new(arg[6, (arg.length - 6)])}
        else
          return {:query => :next}
        end
      else
        raise ArgumentError.new("Invalid long-form argument: `#{arg}`.")
      end
    end



    def check_short_arg(arg = '')
      # `-j` to specify json
      if (arg == 'j')
        return {:printer => :to_json}
      # `-y` to specify yaml
      elsif (arg == 'y')
        return {:printer => :to_yaml}
      # `-q` to query
      elsif (arg[0] == 'q')
        if (arg[1] == '=')
          return {:query => Query.new(arg[1, (arg.length - 1)])}
        else
          return {:query => :next}
        end
      else
        raise ArgumentError.new("Invalid short-form argument: `#{arg}`.")
      end
    end



    def act_on_args(act = { })
      if ((act.has_key?(:infile)) && (act[:infile].is_a?(String)))
        doc = Doc.new(act[:infile])
        doc.parse!

        if ((act.has_key?(:query)) && (act[:query].is_a?(Query)))
          puts "Would filter the nodes with the query `#{act[:query].string}`"
        end

        puts doc.nodes.send(act[:printer])

      else
        raise ArgumentError.new("Nothing to do: no filename given.")
      end
    end

  end
end

Taskpaper::Session.new(ARGV)
