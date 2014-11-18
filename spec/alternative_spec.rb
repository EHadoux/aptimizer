require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Alternative do
  it "has a default probability" do
    a = Arg2MOMDP::Alternative.new(nil)
    expect(a.probability).to eq(1.0)
  end

  it "displays properly with one modifier" do
    m1 = double(:to_s => "+a(a)")
    a = Arg2MOMDP::Alternative.new([m1], 0.5)
    expect(a.to_s).to eq("0.5: +a(a)")
  end

  it "displays properly with multiples modifiers" do
    m1 = double(:to_s => "+a(a)")
    m2 = double(:to_s => "+e(a, b)")
    a = Arg2MOMDP::Alternative.new([m1, m2], 0.5)
    expect(a.to_s).to eq("0.5: +a(a) & +e(a, b)")
  end

  it "returns whether it modifies" do
    m1 = double(:predicate => double(:is? => true))
    m2 = double(:predicate => double(:is? => false))
    a = Arg2MOMDP::Alternative.new([m1, m2], 0.5)
    expect(a.modifies?(nil, nil, nil)).to be_truthy
    a = Arg2MOMDP::Alternative.new([m1], 0.5)
    expect(a.modifies?(nil, nil, nil)).to be_truthy
    a = Arg2MOMDP::Alternative.new([m2], 0.5)
    expect(a.modifies?(nil, nil, nil)).to be_falsey
  end
end
