require "rltk/parser"

module Arg2MOMDP
  class Parser < RLTK::Parser
    production(:input) do
      clause("args")    { |a| a }
      clause("atks")    { |a| a }
      clause("initial") { |i| i }
    end

    nonempty_list(:args, :ARG, :COMMA)

    production(:atk, "ATK ARG COMMA ARG RP") { |_, a, _, b, _| Predicate.new(:atk, a, b) }
    nonempty_list(:atks, :atk, :COMMA)

    production(:predicate) do
      clause("PRIV ARG RP") { |_, a, _| Predicate.new(:priv, a) }
      clause("PUB ARG RP")  { |_, a, _| Predicate.new(:pub, a) }
      clause("atk") { |a| a }
    end
    nonempty_list(:initial, :predicate, :AND)

    finalize({:use => 'parser.tbl'})
  end
end
