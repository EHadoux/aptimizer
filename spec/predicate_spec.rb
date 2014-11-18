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

    it "properly tests the predicate" do
      p = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      expect(p.is?(:atk, 'a', 'b')).to be_truthy
      expect(p.is?(:atk, 'a', 'c')).to be_falsey
      expect(p.is?(:atk, 'b', 'b')).to be_falsey
      expect(p.is?(:pub, nil, nil)).to be_falsey
    end

    it "properly equals" do
      p = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      p3 = Arg2MOMDP::Predicate.new(:atk, 'a', 'c')
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
    end

    it "properly calculate hash" do
      p = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      expect(p.hash).to eq(p2.hash)
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

    it "properly tests the predicate" do
      p = Arg2MOMDP::Predicate.new(:pub, 'a', 'b')
      expect(p.is?(:pub, 'a', 'b')).to be_truthy
      expect(p.is?(:pub, 'a', 'c')).to be_truthy
      expect(p.is?(:pub, 'a')).to be_truthy
      expect(p.is?(:pub, 'b', 'b')).to be_falsey
      expect(p.is?(:atk, nil)).to be_falsey
      expect(p.is?(:priv, nil)).to be_falsey
    end

    it "properly equals" do
      p = Arg2MOMDP::Predicate.new(:pub, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:pub, 'a', 'c')
      p3 = Arg2MOMDP::Predicate.new(:pub, 'b', 'b')
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
    end

    it "properly calculate hash" do
      p = Arg2MOMDP::Predicate.new(:pub, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:pub, 'a', 'c')
      expect(p.hash).to eq(p2.hash)
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

    it "properly tests the predicate" do
      p = Arg2MOMDP::Predicate.new(:priv, 'a', 'b')
      expect(p.is?(:priv, 'a', 'b')).to be_truthy
      expect(p.is?(:priv, 'a', 'c')).to be_truthy
      expect(p.is?(:priv, 'a')).to be_truthy
      expect(p.is?(:priv, 'b', 'b')).to be_falsey
      expect(p.is?(:atk, nil)).to be_falsey
      expect(p.is?(:pub, nil)).to be_falsey
    end

    it "properly equals" do
      p = Arg2MOMDP::Predicate.new(:priv, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:priv, 'a', 'c')
      p3 = Arg2MOMDP::Predicate.new(:atk, 'b', 'b')
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
    end

    it "properly calculate hash" do
      p = Arg2MOMDP::Predicate.new(:priv, 'a', 'b')
      p2 = Arg2MOMDP::Predicate.new(:priv, 'a', 'c')
      expect(p.hash).to eq(p2.hash)
    end
  end
end
