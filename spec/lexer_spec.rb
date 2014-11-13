require 'arg2momdp'
require 'spec_helper'

RSpec.describe Arg2MOMDP::Lexer do
  context "Argument" do
    it "lexes a comma" do
      lexed_arr = Arg2MOMDP::Lexer::lex(",")
      expect(lexed_arr.join(' ')).to eq("COMMA EOS")
    end

    it "lexes a single argument" do
      lexed_arr = Arg2MOMDP::Lexer::lex("a")
      expect(lexed_arr.join(' ')).to eq("ARG(a) EOS")
    end

    it "lexes a list of arguments without space" do
      lexed_arr = Arg2MOMDP::Lexer::lex("a,b,c")
      expect(lexed_arr.join(' ')).to eq("ARG(a) COMMA ARG(b) COMMA ARG(c) EOS")
    end

    it "lexes a list of arguments with space" do
      lexed_arr = Arg2MOMDP::Lexer::lex("a, b, c")
      expect(lexed_arr.join(' ')).to eq("ARG(a) COMMA ARG(b) COMMA ARG(c) EOS")
    end

    it "lexes a list of multi-characters arguments" do
      lexed_arr = Arg2MOMDP::Lexer::lex("aaaa, bbbb, cccc")
      expect(lexed_arr.join(' ')).to eq("ARG(aaaa) COMMA ARG(bbbb) COMMA ARG(cccc) EOS")
    end
  end
end
