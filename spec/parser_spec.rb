require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Parser do
  context "Argument" do
    it "parses a single argument" do
      arg = Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("a"))
      expect(arg).to eq(["a"])
    end

    it "parses a list of arguments" do
      args_arr = Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("a, b, c, d"))
      expect(args_arr.join(' ')).to eq("a b c d")
    end

    it "does not parse a single comma" do
      expect {Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex(","))}.to raise_error
    end
  end

  context "Attack" do
    it "parses a single attack" do
      atk = Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("e(a,b)"))
      expect(atk[0]).to be_a(Arg2MOMDP::Predicate)
      expect(atk.size).to eq(1)
    end

    it "parses a list of attacks" do
      atk_arr = Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("e(a,b), e(aa,bb),e(e,d)"))
      atk_arr.each {|a| expect(a).to be_a(Arg2MOMDP::Predicate)}
      expect(atk_arr.size).to eq(3)
    end

    it "does not parse an attack without two arguments" do
      expect {Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("e(a)"))}.to raise_error
    end
  end

  context "Predicate" do
    it "parses a predicate" do
      pred = Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("a(a)"))
      expect(pred[0]).to be_a(Arg2MOMDP::Predicate)
      expect(pred.size).to eq(1)
    end

    it "does not parse a predicate with two arguments" do
      expect {Arg2MOMDP::Parser::parse(Arg2MOMDP::Lexer::lex("a(a,b)"))}.to raise_error
    end
  end

  context "Initial" do
    it "parses a list of predicate" do
      pred_arr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("a(a) & h(bb) & e(a,b)"))
      pred_arr.each {|p| expect(p).to be_a(Arg2MOMDP::Predicate)}
      expect(pred_arr.size).to eq(3)
    end
  end

  context "Rule" do
    it "parses a rule" do
      rule = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("a(a) => 1.0: +a(b)"))
      expect(rule[0]).to be_a(Arg2MOMDP::Rule)
      expect(rule.size).to eq(1)
      expect(rule[0].premisses.size).to eq(1)
      expect(rule[0].alternatives[0].probability).to eq(1)
      expect(rule[0].alternatives[0].modifiers.size).to eq(1)
    end

    it "does not parse a rule without probability" do
      expect {Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("a(a) => +a(b)"))}.to raise_error
    end

    it "parses a rule with several alternatives" do
      rule_arr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("a(a) => 0.5: +a(b) | 0.5: +a(c)"))
      expect(rule_arr[0].alternatives.size).to eq(2)
    end

    it "parses several rules with several alternatives" do
      rule_arr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex(
                               "a(a) => 0.5: +a(b) | 0.5: +a(c), a(c) & h(b) => 0.7: .+h(c) | 0.3: .+h(d)"))
      expect(rule_arr.size).to eq(2)
    end
  end

  context "Goal" do
    it "parses a goal" do
      goal = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("g(a)"))
      expect(goal).to eq([["a"], []])
    end

    it "parses an anti-goal" do
      goal = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("!g(a)"))
      expect(goal).to eq([[], ["a"]])
    end

    it "parses a list of goals and antigoals" do
      goal_arr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("g(a) & g(b) & !g(a) & !g(b)"))
      expect(goal_arr).to eq([%w(a b), %w(a b)])
    end

    it "does not parse a list of goals and antigoals in the wrong order" do
      expect {Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer::lex("g(a) & !g(b) & !g(a) & g(b)"))}.to raise_error
    end
  end
end
