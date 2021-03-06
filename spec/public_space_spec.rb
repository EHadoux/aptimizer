require "aptimizer"

RSpec.describe Aptimizer::PublicSpace do
  it "checks the initial state coherence" do
    p1 = instance_double("Predicate", :argument1 => "a", :type => :priv)
    p2 = instance_double("Predicate", :argument1 => "b", :type => :pub)
    p3 = instance_double("Predicate", :argument1 => "a", :argument2 => "b", :type => :atk)

    agent = Aptimizer::PublicSpace.new(%w(a b c), [p3], [p1, p2, p3])
    expect(agent.initial_state.size).to eq(2)
  end

  it "checks the errors on the initial state" do
    p4 = instance_double("Predicate", :argument1 => "d", :type => :pub)
    p5 = instance_double("Predicate", :argument1 => "d", :type => :priv)
    p6 = instance_double("Predicate", :argument1 => "a", :argument2 => "d", :type => :atk)
    p7 = instance_double("Predicate", :argument1 => "a", :argument2 => "b", :type => :atk)

    expect {Aptimizer::PublicSpace.new(%w(a b c), [], [p4])}.to raise_error
    expect {Aptimizer::PublicSpace.new(%w(a b c), [], [p6])}.to raise_error
    expect {Aptimizer::PublicSpace.new(%w(a b c), [], [p7])}.to raise_error
    expect(Aptimizer::PublicSpace.new(%w(a b c), [p7], [p7]).initial_state.size).to eq(1)
    expect(Aptimizer::PublicSpace.new(%w(a b c), [], [p5]).initial_state.size).to eq(0)
    expect {Aptimizer::PublicSpace.new(%w(a b c), [], [p5])}.to_not raise_error
  end
end