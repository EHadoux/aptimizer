require "aptimizer"

RSpec.describe Aptimizer::Alternative do
  it "displays properly with one modifier" do
    m1 = instance_double("Aptimizer::Modifier", :to_s => "+a(a)")
    a  = Aptimizer::Alternative.new([m1], 0.5)
    expect(a.to_s).to eq("0.5: +a(a)")
  end

  it "displays properly with multiples modifiers" do
    m1 = instance_double("Aptimizer::Modifier", :to_s => "+a(a)")
    m2 = instance_double("Aptimizer::Modifier", :to_s => "+e(a, b)")
    a  = Aptimizer::Alternative.new([m1, m2], 0.5)
    expect(a.to_s).to eq("0.5: +a(a) & +e(a, b)")
  end

  it "returns whether it modifies" do
    p1 = instance_double("Aptimizer::Predicate", :== => true, :unsided => p1)
    p2 = instance_double("Aptimizer::Predicate", :== => false, :unsided => p2)
    m1 = instance_double("Aptimizer::Modifier", :predicate => p1)
    m2 = instance_double("Aptimizer::Modifier", :predicate => p2)
    a = Aptimizer::Alternative.new([m1, m2], 0.5)
    expect(a.modifies?(p1)).to be_truthy
    a = Aptimizer::Alternative.new([m1], 0.5)
    expect(a.modifies?(p1)).to be_truthy
    a = Aptimizer::Alternative.new([m2], 0.5)
    expect(a.modifies?(p1)).to be_falsey
  end
end
