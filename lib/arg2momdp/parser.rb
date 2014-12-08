require "rltk/parser"

module Arg2MOMDP
  class Parser < RLTK::Parser
    production(:input) do
      clause("args")      { |a| a }
      clause("atks")      { |a| a }
      clause("rules")     { |r| r }
      clause("initial")   { |i| i }
      clause("goalslist") { |g| g }
    end

    nonempty_list(:args, :ARG, :COMMA)

    production(:atk, "ATK ARG COMMA ARG RP") { |_, a, _, b, _| Predicate.new(:atk, a, arg2:b) }
    nonempty_list(:atks, :atk, :COMMA)

    production(:rule, "premisses IMPLIES alternatives") { |p, _, c| Rule.new(p,c) }
    nonempty_list(:rules, :rule, :COMMA)

    nonempty_list(:premisses, :negablepredicate, :AND)
    production(:negablepredicate) do
      clause("predicate")     { |p| p            }
      clause("NOT predicate") { |_, p| p.negate! }
    end

    production(:predicate) do
      clause("PRIV ARG RP") { |_, a, _| Predicate.new(:priv, a) }
      clause("PUB ARG RP")  { |_, a, _| Predicate.new(:pub, a) }
      clause("atk") { |a| a }
    end
    nonempty_list(:alternatives, :alternative, :OR)
    production(:alternative, "PROBA COLON claims") { |p, _, c| Alternative.new(c, p) }
    nonempty_list(:claims, :modifier, :AND)
    production(:modifier) do
      clause("PUBPLUS predicate")   { |_, p| Modifier.new(:add, :pub, p)  }
      clause("PUBMINUS predicate")  { |_, p| Modifier.new(:rem, :pub, p)  }
      clause("PRIVPLUS predicate")  { |_, p| Modifier.new(:add, :priv, p) }
      clause("PRIVMINUS predicate") { |_, p| Modifier.new(:rem, :priv, p) }
    end

    nonempty_list(:initial, :predicate, :AND)

    production(:goalslist) do
      clause("goals AND antigoals") { |g, _, ag| [g,  ag] }
      clause("goals")               { |g|        [g,  []] }
      clause("antigoals")           { |ag|       [[], ag] }
    end
    list(:goals, :goal, :AND)
    list(:antigoals, :antigoal, :AND)
    production(:goal, "GOAL ARG RP")         { |_, a, _| a    }
    production(:antigoal, "NOT GOAL ARG RP") { |_, _, a, _| a }

    finalize({:use => 'parser.tbl'})
  end
end
