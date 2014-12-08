require "arg2momdp"

RSpec.describe Arg2MOMDP::POMDPX::Opponent do
  it "gives 0 flag with 1 rule 1 alternative" do
    r1 = double(:alternatives => [""])
    opponent = Arg2MOMDP::POMDPX::Opponent.new(nil, [r1])
    expect(opponent.flags).to eq([])
  end

  it "gives 0 flag with 2 rules 1 alternative" do
    r1 = double(:alternatives => [""])
    r2 = double(:alternatives => [""])
    opponent = Arg2MOMDP::POMDPX::Opponent.new(nil, [r1, r2])
    expect(opponent.flags).to eq([])
  end

  it "gives 2 flags with 1 rule 2 alternatives" do
    r1 = double(:alternatives => ["", ""])
    opponent = Arg2MOMDP::POMDPX::Opponent.new(nil, [r1])
    expect(opponent.flags).to eq([0])
  end

  it "gives 4 flags with 2 rules 2 alternatives" do
    r1 = double(:alternatives => ["", ""])
    r2 = double(:alternatives => ["", ""])
    opponent = Arg2MOMDP::POMDPX::Opponent.new(nil, [r1, r2])
    expect(opponent.flags).to eq([0,1])
  end

  it "gives the proper number for the flags" do
    r1 = double(:alternatives => ["", ""])
    r2 = double(:alternatives => [""])
    r3 = double(:alternatives => ["", ""])
    opponent = Arg2MOMDP::POMDPX::Opponent.new(nil, [r1, r2, r3])
    expect(opponent.flags).to eq([0,2])
  end
end