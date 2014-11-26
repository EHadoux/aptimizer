require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Rule do
  before(:each) do
    @a1 = double(:probability => 1, :modifies? => false)
    @a2 = double(:probability => 0.5, :to_s => "0.5: +a(a) & .-h(b)", :modifies? => true)
    @a3 = double(:probability => 0.5, :to_s => "0.5: +e(a,b) & .+a(b)", :modifies => false)
  end

  it "raises an error if the sum of probabilities is not 1.0 with one alternative" do
    expect {Arg2MOMDP::Rule.new(nil, [@a2])}.to raise_error
  end

  it "raises an error if the sum of probabilities is not 1.0 with several alternatives" do
    expect {Arg2MOMDP::Rule.new(nil, [@a1, @a2])}.to raise_error
  end

  it "does not raise an error if the sum of probabilities is 1.0 with one alternatives" do
    expect {Arg2MOMDP::Rule.new(nil, [@a1])}.to_not raise_error
  end

  it "does not raise an error if the sum of probabilities is 1.0 with several alternatives" do
    expect {Arg2MOMDP::Rule.new(nil, [@a2, @a3])}.to_not raise_error
  end

  it "displays properly" do
    p1 = double(:to_s => "a(a)")
    p2 = double(:to_s => "e(a,b)")
    r  = Arg2MOMDP::Rule.new([p1,p2], [@a2, @a3])
    expect(r.to_s).to eq("a(a) & e(a,b) => 0.5: +a(a) & .-h(b) | 0.5: +e(a,b) & .+a(b)")
  end

  it "returns whether it modifies" do
    p1 = double(:to_s => "a(a)")
    p2 = double(:to_s => "e(a,b)")
    r  = Arg2MOMDP::Rule.new([p1,p2], [@a1])
    expect(r.modifies?(nil)).to be_falsey
    r  = Arg2MOMDP::Rule.new([p1,p2], [@a2, @a3])
    expect(r.modifies?(nil)).to be_truthy
  end
end