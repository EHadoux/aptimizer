require "arg2momdp"

RSpec.describe Arg2MOMDP::POMDPX::Agent do
  it "checks the initial state coherence" do
    p1 = instance_double("Predicate", :argument1 => "a", :type => :priv)
    p2 = instance_double("Predicate", :argument1 => "b", :type => :pub)
    p3 = instance_double("Predicate", :argument1 => "a", :argument2 => "b", :type => :atk)

    agent = Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [], [p1, p2, p3])
    expect(agent.initial_state.size).to eq(1)
  end

  it "checks the errors on the initial state" do
    p4 = instance_double("Predicate", :argument1 => "d", :type => :pub)
    p5 = instance_double("Predicate", :argument1 => "d", :type => :priv)

    expect {Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [], [p4])}.to_not raise_error
    expect(Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [], [p4]).initial_state.size).to eq(0)
    expect {Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [], [p5])}.to raise_error
  end

  it "properly defines actions" do
    r1 = instance_double("Rule", :premisses => [],
                         :alternatives => [instance_double("Alternative", :to_s => "+a(a) & +e(a,b)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => []),
                                           instance_double("Alternative", :to_s => "-h(a) & -h(c)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => [])])
    r2 = instance_double("Rule", :premisses => [],
                         :alternatives => [instance_double("Alternative", :to_s => "-a(a)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => [])])
    agent = Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [r1, r2], [])
    expect(agent.actions.size).to eq(3)
    agent.actions.each {|a| expect(a.alternatives.size).to eq(1)}
  end

  it "properly defaults the action names" do
    r1 = instance_double("Rule", :premisses => [],
                         :alternatives => [instance_double("Alternative", :to_s => "+a(a) & +e(a,b)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => []),
                                           instance_double("Alternative", :to_s => "-h(a) & -h(c)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => [])])
    r2 = instance_double("Rule", :premisses => [],
                         :alternatives => [instance_double("Alternative", :to_s => "-a(a)",
                                                           :probability => 1.0, :probability= => 1.0,
                                                           :modifiers => [])])
    agent = Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [r1, r2], [])
    expect(agent.action_names).to eq(%w(a0 a1 a2))
    agent = Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [r1, r2], [], [[],[]], %w(adda addb addc))
    expect(agent.action_names).to eq(%w(adda addb addc))
    expect { Arg2MOMDP::POMDPX::Agent.new(%w(a b c), [r1, r2], [], [[],[]], %w(adda addb)) }.to raise_error
  end
end
