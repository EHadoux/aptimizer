require "arg2momdp"

RSpec.describe Arg2MOMDP::Predicate do
  it "raises en error if the type is unknown" do
    expect {Arg2MOMDP::Predicate.new(:unknown, 'a', 'b')}.to raise_error
  end

  context "Attack" do
    it "shows the right predicate" do
      p = Arg2MOMDP::Predicate.new(:atk, 'a', 'b')
      expect(p.to_s).to eq("e(a, b)")
    end
  end
end
