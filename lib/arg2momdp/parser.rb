require "rltk/parser"

module Arg2MOMDP
  class Parser < RLTK::Parser
    production(:input) do
      clause("args")    { |a| a }
      clause("atks")    { |a| a }
    end

    nonempty_list(:args, :ARG, :COMMA)

    production(:atk, "ATK ARG COMMA ARG RP") { |_, a, _, b, _| Predicate.new(:atk, a, b) }
    nonempty_list(:atks, :atk, :COMMA)

    finalize({:use => 'parser.tbl'})
  end
end
