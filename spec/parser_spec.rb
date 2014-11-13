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
end
