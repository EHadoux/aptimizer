require "rltk/lexer"

module Arg2MOMDP
  class Lexer < RLTK::Lexer
    rule(/\s/)
    rule(/,/)                   { :COMMA               }
    rule(/[a-z]+/)              { |a| [:ARG, a]        }
    rule(/e\(/)                 { :ATK                 }
    rule(/\)/)                  { :RP                  }
    rule(/h\(/)                 { :PRIV                }
    rule(/a\(/)                 { :PUB                 }
    rule(/(0\.[0-9]+|1(\.0)?)/) { |p| [:PROBA, p.to_f] }
    rule(/&/)                   { :AND                 }
    rule(/\|/)                  { :OR                  }
    rule(/:/)                   { :COLON               }
    rule(/=>/)                  { :IMPLIES             }
    rule(/\+/)                  { :PUBPLUS             }
    rule(/-/)                   { :PUBMINUS            }
    rule(/\.\+/)                { :PRIVPLUS            }
    rule(/\.-/)                 { :PRIVMINUS           }
  end
end
