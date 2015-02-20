require "aptimizer"

RSpec.describe Aptimizer::Predicate do
  it "raises en error if the type is unknown" do
    expect {Aptimizer::Predicate.new(:unknown, 'a', arg2:'b')}.to raise_error
  end

  it "has a default nil 2nd argument" do
    p = Aptimizer::Predicate.new(:priv, 'a')
    expect(p.argument2).to be_nil
  end

  it "is positive by default" do
    p = Aptimizer::Predicate.new(:priv, 'a')
    expect(p.positive).to be_truthy
  end

  it "properly initialize the owner" do
    p = Aptimizer::Predicate.new(:priv, 'a')
    expect(p.owner).to eq(1)
    p = Aptimizer::Predicate.new(:priv, 'a', owner:2)
    expect(p.owner).to eq(2)
  end

  it "properly clones" do
    p  = Aptimizer::Predicate.new(:priv, 'a')
    p2 = p.clone
    expect(p.type).to eq(p2.type)
    expect(p.argument1).to eq(p2.argument1)
    expect(p.argument2).to eq(p2.argument2)
    expect(p.positive).to eq(p2.positive)
    p2.negate!
    expect(p.positive).to_not eq(p2.positive)
  end

  it "properly negates" do
    p    = Aptimizer::Predicate.new(:priv, 'a')
    pos  = p.positive
    p2   = Aptimizer::Predicate.new(:priv, 'a')
    pos2 = p2.positive
    p.negate!
    p2.negate
    expect(p.positive).to_not eq(pos)
    expect(p2.positive).to eq(pos2)
  end

  it "properly unside" do
    p  = Aptimizer::Predicate.new(:priv, 'a')
    p2 = Aptimizer::Predicate.new(:priv, 'a', positive:false)
    expect(p.unsided.positive).to be_truthy
    expect(p.positive).to be_truthy
    expect(p2.unsided.positive).to be_truthy
    expect(p2.positive).to be_falsey
  end

  it "properly changes the owner" do
    p = Aptimizer::Predicate.new(:priv, 'a')
    p.change_owner(2)
    expect(p.owner).to eq(2)
    p = Aptimizer::Predicate.new(:priv, 'a', owner:2)
    p.change_owner(1)
    expect(p.owner).to eq(1)
  end

  context "Attack" do
    it "shows the right predicate" do
      p = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      expect(p.to_s).to eq("e(a, b)")
      p = Aptimizer::Predicate.new(:atk, 'a', arg2:'b', positive:false)
      expect(p.to_s).to eq("!e(a, b)")
    end

    it "properly tests the predicate" do
      p = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      expect(p.is?(:atk, 'a', 'b')).to be_truthy
      expect(p.is?(:atk, 'a', 'b', false)).to be_falsey
      expect(p.is?(:atk, 'a', 'c')).to be_falsey
      expect(p.is?(:atk, 'b', 'b')).to be_falsey
      expect(p.is?(:pub, nil, nil)).to be_falsey
    end

    it "properly equals" do
      p  = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      p3 = Aptimizer::Predicate.new(:atk, 'a', arg2:'c')
      p4 = Aptimizer::Predicate.new(:atk, 'a', arg2:'b', positive:false)
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
      expect(p.eql?(p4)).to be_falsey
      expect(p == p4).to be_falsey
    end

    it "properly calculate hash" do
      p  = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:atk, 'a', arg2:'b')
      p3 = Aptimizer::Predicate.new(:atk, 'a', arg2:'b', positive:false)
      expect(p.hash).to eq(p2.hash)
      expect(p.hash).to_not eq(p3.hash)
    end
  end

  context "Public" do
    it "shows the right predicate" do
      p = Aptimizer::Predicate.new(:pub, 'a')
      expect(p.to_s).to eq("a(a)")
      p = Aptimizer::Predicate.new(:pub, 'a', positive:false)
      expect(p.to_s).to eq("!a(a)")
    end

    it "ignores the 2nd argument" do
      p = Aptimizer::Predicate.new(:pub, 'a', arg2:'b')
      expect(p.to_s).to eq("a(a)")
    end

    it "properly tests the predicate" do
      p = Aptimizer::Predicate.new(:pub, 'a', arg2:'b')
      expect(p.is?(:pub, 'a', 'b')).to be_truthy
      expect(p.is?(:pub, 'a', 'b', false)).to be_falsey
      expect(p.is?(:pub, 'a', 'c')).to be_truthy
      expect(p.is?(:pub, 'a')).to be_truthy
      expect(p.is?(:pub, 'b', 'b')).to be_falsey
      expect(p.is?(:atk, nil)).to be_falsey
      expect(p.is?(:priv, nil)).to be_falsey
    end

    it "properly equals" do
      p  = Aptimizer::Predicate.new(:pub, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:pub, 'a', arg2:'c')
      p3 = Aptimizer::Predicate.new(:pub, 'b', arg2:'b')
      p4 = Aptimizer::Predicate.new(:pub, 'a', arg2:'b', positive:false)
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
      expect(p.eql?(p4)).to be_falsey
      expect(p == p4).to be_falsey
    end

    it "properly calculate hash" do
      p  = Aptimizer::Predicate.new(:pub, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:pub, 'a', arg2:'c')
      p3 = Aptimizer::Predicate.new(:pub, 'a', arg2:'b', positive:false)
      expect(p.hash).to eq(p2.hash)
      expect(p.hash).to_not eq(p3.hash)
    end
  end

  context "Private" do
    it "shows the right predicate" do
      p = Aptimizer::Predicate.new(:priv, 'a')
      expect(p.to_s).to eq("h(a)")
      p = Aptimizer::Predicate.new(:priv, 'a', positive:false)
      expect(p.to_s).to eq("!h(a)")
    end

    it "ignores the 2nd argument" do
      p = Aptimizer::Predicate.new(:priv, 'a', arg2:'b')
      expect(p.to_s).to eq("h(a)")
    end

    it "properly tests the predicate" do
      p = Aptimizer::Predicate.new(:priv, 'a', arg2:'b')
      expect(p.is?(:priv, 'a', 'b')).to be_truthy
      expect(p.is?(:priv, 'a', 'b', false)).to be_falsey
      expect(p.is?(:priv, 'a', 'c')).to be_truthy
      expect(p.is?(:priv, 'a')).to be_truthy
      expect(p.is?(:priv, 'b', 'b')).to be_falsey
      expect(p.is?(:atk, nil)).to be_falsey
      expect(p.is?(:pub, nil)).to be_falsey
    end

    it "properly equals" do
      p  = Aptimizer::Predicate.new(:priv, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:priv, 'a', arg2:'c')
      p3 = Aptimizer::Predicate.new(:atk, 'b', arg2:'b')
      p4 = Aptimizer::Predicate.new(:priv, 'a', arg2:'b', positive:false)
      expect(p.eql?(p2)).to be_truthy
      expect(p == p2).to be_truthy
      expect(p.eql?(p3)).to be_falsey
      expect(p == p3).to be_falsey
      expect(p.eql?(p4)).to be_falsey
      expect(p == p4).to be_falsey
    end

    it "properly calculate hash" do
      p  = Aptimizer::Predicate.new(:priv, 'a', arg2:'b')
      p2 = Aptimizer::Predicate.new(:priv, 'a', arg2:'c')
      p3 = Aptimizer::Predicate.new(:priv, 'a', arg2:'b', positive:false)
      expect(p.hash).to eq(p2.hash)
      expect(p.hash).to_not eq(p3.hash)
    end
  end
end
