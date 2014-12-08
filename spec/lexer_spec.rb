require "arg2momdp"

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

  context "Attack" do
    it "lexes an attack" do
      lexed_arr = Arg2MOMDP::Lexer::lex("e(a,bb)")
      expect(lexed_arr.join(" ")).to eq("ATK ARG(a) COMMA ARG(bb) RP EOS")
    end

    it "lexes a list of attacks" do
      lexed_arr = Arg2MOMDP::Lexer::lex("e(a,bb), e(e, cc)")
      expect(lexed_arr.join(" ")).to eq("ATK ARG(a) COMMA ARG(bb) RP COMMA ATK ARG(e) COMMA ARG(cc) RP EOS")
    end
  end

  context "Predicate" do
    it "lexes a predicate" do
      lexed_arr = Arg2MOMDP::Lexer::lex("a(a)")
      expect(lexed_arr.join(" ")).to eq("PUB ARG(a) RP EOS")

      lexed_arr = Arg2MOMDP::Lexer::lex("h(aa)")
      expect(lexed_arr.join(" ")).to eq("PRIV ARG(aa) RP EOS")
    end
  end

  context "Initial" do
    it "lexes a list of predicates" do
      lexed_arr = Arg2MOMDP::Lexer::lex("a(a) & h(bb) & e(a,b)")
      expect(lexed_arr.join(" ")).to eq("PUB ARG(a) RP AND PRIV ARG(bb) RP AND ATK ARG(a) COMMA ARG(b) RP EOS")
    end
  end

  context "Modifier" do
    it "lexes all the modifiers" do
      lexed_arr = Arg2MOMDP::Lexer::lex("+ - .+ .-")
      expect(lexed_arr.join(" ")).to eq("PUBPLUS PUBMINUS PRIVPLUS PRIVMINUS EOS")
    end

    it "lexes a modifier and a predicate" do
      lexed_arr = Arg2MOMDP::Lexer::lex(".+h(bbb)")
      expect(lexed_arr.join(" ")).to eq("PRIVPLUS PRIV ARG(bbb) RP EOS")
    end
  end

  context "Probability" do
    it "lexes a probability" do
      proba = Arg2MOMDP::Lexer::lex("0.45")
      expect(proba.join(" ")).to eq("PROBA(0.45) EOS")
    end

    it "lexes 1.0" do
      proba = Arg2MOMDP::Lexer::lex("1.0")
      expect(proba.join(" ")).to eq("PROBA(1.0) EOS")
    end

    it "lexes 1" do
      proba = Arg2MOMDP::Lexer::lex("1")
      expect(proba.join(" ")).to eq("PROBA(1.0) EOS")
    end

    it "does not lex a probability > 1.0" do
      expect {Arg2MOMDP::Lexer::lex("1.4")}.to raise_error
    end
  end

  context "Rules" do
    it "lexes a OR" do
      r = Arg2MOMDP::Lexer::lex("|")
      expect(r.join(" ")).to eq("OR EOS")
    end
  end

  context "Goal" do
    it "lexes a goal" do
      g = Arg2MOMDP::Lexer::lex("g(a)")
      expect(g.join(" ")).to eq("GOAL ARG(a) RP EOS")
    end

    it "lexes an anti-goal" do
      g = Arg2MOMDP::Lexer::lex("!g(a)")
      expect(g.join(" ")).to eq("NOT GOAL ARG(a) RP EOS")
    end
  end
end
