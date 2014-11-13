require "rltk/lexer"

module Arg2MOMDP
  class Lexer < RLTK::Lexer
    rule(/\s/)
    rule(/,/)                   { :COMMA          }
    rule(/[a-z]+/)              { |a| [:ARG, a]   }
    rule(/e\(/)                 { :ATK            }
    rule(/\)/)                  { :RP             }
  end
end
