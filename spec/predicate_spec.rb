require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Predicate do
  it "raises en error if the type is unknown" do
    expect {Arg2MOMDP::Predicate.new(:unknown, 'a', 'b')}.to raise_error
  end

  it "has a default nil 2nd argument" do
    p = Arg2MOMDP::Predicate.new(:priv, 'a')
    expect(p.argument2).to be_nil
  end

  context "Attack" do
    it "shows the right predicate" do
      p = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      expect(p.to_s).to eq("e(a, b)")
    end
  end

  context "Public" do
    it "shows the right predicate" do
      p = Arg2MOMDP::Predicate.new(:pub, 'a')
      expect(p.to_s).to eq("a(a)")
    end

    it "ignores the 2nd argument" do
      p = Arg2MOMDP::Predicate.new(:pub, 'a', 'b')
      expect(p.to_s).to eq("a(a)")
    end
  end

  context "Private" do
    it "shows the right predicate" do
      p = Arg2MOMDP::Predicate.new(:priv, 'a')
      expect(p.to_s).to eq("h(a)")
    end

    it "ignores the 2nd argument" do
      p = Arg2MOMDP::Predicate.new(:priv, 'a', 'b')
      expect(p.to_s).to eq("h(a)")
    end
  end
end
