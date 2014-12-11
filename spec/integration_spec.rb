require "arg2momdp"

RSpec.describe "Integration" do
  context "without optimization" do
    it "properly parses and build the example" do
      arguments    = "a,b,c,d,e,f,g,h"
      attacks      = "e(f,a), e(g,a), e(b,f), e(c,f), e(g,c), e(d,g), e(e,g), e(h,b)"
      rules1       = "h(a) => 1.0: +a(a),
                     h(b) & a(f) & h(c) & !e(b,f) & !e(c,f) => 0.5: +a(b) & +e(b,f) | 0.5: +a(c) & +e(c,f),
                     h(d) & a(g) & h(e) & !e(d,g) & !e(e,g) => 0.8: +a(e) & +e(e,g) | 0.2: +a(d) & +e(d,g)"
      rules2       = "h(h) & a(b) & !e(h,b) => 1.0: +a(h) & +e(h,b),
                     h(g) & a(c) & !e(g,c) => 1.0: +a(g) & +e(g,c),
                     a(a) & h(f) & h(g) & !e(f,a) & !e(g,a) => 0.8: +a(f) & +e(f,a) | 0.2: +a(g) & +e(g,a)"
      initial      = "h(a) & h(b) & h(c) & h(d) & h(e)"
      goals        = "g(a)"
      action_names = "adda, addb, addc, adde, addd"

      argarr   = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(arguments))
      atkarr   = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(attacks))
      r1arr    = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(rules1))
      r2arr    = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(rules2))
      initarr  = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(initial))
      actarr   = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(action_names))
      goalsarr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(goals))

      agent       = Arg2MOMDP::Agent.new(argarr, r1arr, initarr, goalsarr, actarr)
      actions_str = ["h(a) & !a(a) => 1.0: +a(a)",
                     "h(b) & a(f) & h(c) & !e(b, f) & !e(c, f) & !a(b) & !a(c) => 1.0: +a(b) & +e(b, f)",
                     "h(b) & a(f) & h(c) & !e(b, f) & !e(c, f) & !a(b) & !a(c) => 1.0: +a(c) & +e(c, f)",
                     "h(d) & a(g) & h(e) & !e(d, g) & !e(e, g) & !a(e) & !a(d) => 1.0: +a(e) & +e(e, g)",
                     "h(d) & a(g) & h(e) & !e(d, g) & !e(e, g) & !a(e) & !a(d) => 1.0: +a(d) & +e(d, g)"]
      expect(agent.actions.map {|a| a.to_s}).to eq(actions_str)

      opponent  = Arg2MOMDP::Opponent.new(argarr, r2arr)
      rules_str = ["h(h) & a(b) & !e(h, b) & !a(h) => 1.0: +a(h) & +e(h, b)",
                   "h(g) & a(c) & !e(g, c) & !a(g) => 1.0: +a(g) & +e(g, c)",
                   "a(a) & h(f) & h(g) & !e(f, a) & !e(g, a) & !a(f) & !a(g) => 0.8: +a(f) & +e(f, a) | 0.2: +a(g) & +e(g, a)"]
      expect(opponent.rules.map {|r| r.to_s}).to eq(rules_str)

      public_space = Arg2MOMDP::PublicSpace.new(argarr, atkarr, initarr)

      pomdp = Arg2MOMDP::POMDP.new(0.9, agent, opponent, public_space)

      puts Arg2MOMDP::POMDPX::XMLBuilder.new(1, "argumentation", pomdp).build_pomdpx
    end
  end
end