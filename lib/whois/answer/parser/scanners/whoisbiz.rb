#
# = Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
#
# Category::    Net
# Package::     Whois
# Author::      Simone Carletti <weppos@weppos.net>
# License::     MIT License
#
#--
#
#++


require 'whois/answer/parser/scanners/base'


module Whois
  class Answer
    class Parser
      module Scanners

        class Whoisbiz < Scanners::Base

          def parse_content
            parse_available   ||
            parse_keyvalue    ||
            skip_lastupdate   ||
            skip_fuffa        ||
            trim_newline      ||
            error!("Unexpected token")
          end


          def skip_lastupdate
            @input.skip(/>>>(.+?)<<<\n/)
          end

          def skip_fuffa
            @input.scan(/^\S(.+)\n/)
          end

          def skip_unless_keyvalue
            if !@input.match?(/(.+?):(.*?)\n/)
              @input.scan(/.*\n/)
            end
          end

          def parse_available
            if @input.scan(/^Not found: (.+)\n/)
              @ast["Domain Name"] = @input[1]
              @ast["status-available"] = true
            end
          end

          def parse_keyvalue
            if @input.scan(/(.+?):(.*?)\n/)
              key, value = @input[1].strip, @input[2].strip
              if @ast[key].nil?
                @ast[key] = value
              else
                @ast[key].is_a?(Array) || @ast[key] = [@ast[key]]
                @ast[key] << value
              end
            end
          end

        end

      end
    end
  end
end
