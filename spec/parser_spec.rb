require 'arg2momdp'
require 'spec_helper'

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
  end
end
