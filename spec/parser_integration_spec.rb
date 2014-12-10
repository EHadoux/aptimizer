require "arg2momdp"
require "spec_helper"

RSpec.describe do
  it "properly parses the example" do
    arguments = "a,b,c,d,e,f,g,h"
    attacks   = "e(f,a), e(g,a), e(b,f), e(c,f), e(g,c), e(d,g), e(e,g), e(h,b)"
    goals     = "g(a)"
    initial   = "a(a) & a(b) & a(c) & a(d) & a(e)"
    rules1    = "h(a) => 1.0: +a(a),
                 h(b) & a(f) & h(c) & !e(b,f) & !e(c,f) => 0.5: +a(b) & +e(b,f) | 0.5: +a(c) & +e(c,f),
                 h(d) & a(g) & h(e) & !e(d,g) & !e(e,g) => 0.8: +a(e) & +e(e,g) | 0.2: +a(d) & +e(d,g)"
    rules2    = "h(h) & a(b) & !e(h,b) => 1.0: +a(h) & +e(h,b),
                 h(g) & a(c) & !e(g,c) => 1.0: +a(g) & +e(g,c),
                 a(a) & h(f) & h(g) & !e(f,a) => 0.8: +a(f) & +e(f,a) | 0.2: +a(g) & +e(g,a)"

    argarr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(arguments))
    atkarr = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(attacks))
    garr   = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(goals))
    iarr   = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(initial))
    r1arr  = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(rules1))
    r2arr  = Arg2MOMDP::Parser.parse(Arg2MOMDP::Lexer.lex(rules2))

    expect(argarr).to eq(%w(a b c d e f g h))
    expect(iarr.size).to eq(5)
    iarr.each do |a|
      expect(a).to be_a(Arg2MOMDP::Predicate)
      expect(a.type).to eq(:pub)
    end
    expect(atkarr.size).to eq(8)
    atkarr.each do |a|
      expect(a).to be_a(Arg2MOMDP::Predicate)
      expect(a.type).to eq(:atk)
    end
    expect(garr).to eq([["a"], []])
    expect(r1arr.size).to eq(3)
    r1arr.each {|r| expect(r).to be_a(Arg2MOMDP::Rule)}
    expect(r2arr.size).to eq(3)
    r2arr.each {|r| expect(r).to be_a(Arg2MOMDP::Rule)}
  end
end