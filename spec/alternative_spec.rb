require "arg2momdp"
require "spec_helper"

RSpec.describe Arg2MOMDP::Alternative do
  it "has a default probability" do
    c = Arg2MOMDP::Alternative.new(nil)
    expect(c.probability).to eq(1.0)
  end

  it "displays properly with one modifier" do
    m1 = double(:to_s => "+a(a)")
    c = Arg2MOMDP::Alternative.new([m1], 0.5)
    expect(c.to_s).to eq("0.5: +a(a)")
  end

  it "displays properly with multiples modifiers" do
    m1 = double(:to_s => "+a(a)")
    m2 = double(:to_s => "+e(a, b)")
    c = Arg2MOMDP::Alternative.new([m1, m2], 0.5)
    expect(c.to_s).to eq("0.5: +a(a) & +e(a, b)")
  end
end
