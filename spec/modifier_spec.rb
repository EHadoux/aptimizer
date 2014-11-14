require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Modifier do
  it "raises an error if the scope is unknown" do
    expect {Arg2MOMDP::Modifier.new(nil, :unknown, nil)}.to raise_error
  end

  it "raises an error if the type is unknown" do
    expect {Arg2MOMDP::Modifier.new(:unknown, nil, nil)}.to raise_error
  end

  context "Public" do
    before(:each) do
      @pred_pub = double(:type => :pub, :to_s => "a(a)")
    end

    it "raises an error if the scope is private and the predicate public" do
      expect {Arg2MOMDP::Modifier.new(:add, :priv, @pred_pub)}.to raise_error
    end

    it "displays properly" do
      m = Arg2MOMDP::Modifier.new(:add, :pub, @pred_pub)
      expect(m.to_s).to eq("+#{@pred_pub}")
      m = Arg2MOMDP::Modifier.new(:rem, :pub, @pred_pub)
      expect(m.to_s).to eq("-#{@pred_pub}")
    end
  end

  context "Private" do
    before(:each) do
      @pred_priv = double(:type => :priv, :to_s => "h(a)")
      @pred_atk  = double(:type => :atk, :to_s => "e(a, b)")
    end

    it "raises an error if the scope is public and the predicate private" do
      expect {Arg2MOMDP::Modifier.new(:add, :pub, @pred_priv)}.to raise_error
    end

    it "raises an error if the scope is private and the predicate is an attack" do
      expect {Arg2MOMDP::Modifier.new(:add, :priv, @pred_atk)}.to raise_error
    end

    it "displays properly" do
      m = Arg2MOMDP::Modifier.new(:add, :priv, @pred_priv)
      expect(m.to_s).to eq(".+#{@pred_priv}")
      m = Arg2MOMDP::Modifier.new(:rem, :priv, @pred_priv)
      expect(m.to_s).to eq(".-#{@pred_priv}")
    end
  end
end
