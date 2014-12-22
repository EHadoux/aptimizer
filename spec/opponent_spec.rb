require "arg2momdp"

RSpec.describe Arg2MOMDP::Opponent do
  it "gives 0 flag with 1 rule 1 alternative" do
    r1 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil)])
    opponent = Arg2MOMDP::Opponent.new(nil, [r1])
    expect(opponent.flags).to eq([])
  end

  it "gives 0 flag with 2 rules 1 alternative" do
    r1 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "a")])
    r2 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "b")])
    opponent = Arg2MOMDP::Opponent.new(nil, [r1, r2])
    expect(opponent.flags).to eq([])
  end

  it "gives 2 flags with 1 rule 2 alternatives" do
    r1 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => []),
                                                   instance_double("Alternative", :modifiers => [])], :premises => [])
    opponent = Arg2MOMDP::Opponent.new(nil, [r1])
    expect(opponent.flags).to eq([0])
  end

  it "gives 4 flags with 2 rules 2 alternatives" do
    r1 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => []),
                                                   instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "a")])
    r2 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => []),
                                                   instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "b")])
    opponent = Arg2MOMDP::Opponent.new(nil, [r1, r2])
    expect(opponent.flags).to eq([0,1])
  end

  it "gives the proper number for the flags" do
    r1 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => []),
                                                   instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "a")])
    r2 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "b")])
    r3 = instance_double("Rule", :alternatives => [instance_double("Alternative", :modifiers => []),
                                                   instance_double("Alternative", :modifiers => [])],
                         :premises => [instance_double("Predicate", :change_owner => nil, :arg1 => "c")])
    opponent = Arg2MOMDP::Opponent.new(nil, [r1, r2, r3])
    expect(opponent.flags).to eq([0,2])
  end
end