require "aptimizer"

RSpec.describe Aptimizer::Rule do
  before(:each) do
    @p1  = instance_double("Arg2MOMDP::Predicate", :to_s => "a(a)")
    @p11 = instance_double("Arg2MOMDP::Predicate", :negate => @p1, :to_s => "!a(a)")
    allow(@p1).to  receive(:negate) { @p11 }
    allow(@p11).to receive(:negate) { @p1  }
    @p2  = instance_double("Arg2MOMDP::Predicate", :to_s => "e(a,b)")
    @p22 = instance_double("Arg2MOMDP::Predicate", :to_s => "!e(a,b)")
    allow(@p2).to  receive(:negate) { @p22 }
    allow(@p22).to receive(:negate) { @p2  }
    @p3  = instance_double("Arg2MOMDP::Predicate", :to_s => "a(b)")
    @p33 = instance_double("Arg2MOMDP::Predicate", :to_s => "!a(b)")
    allow(@p3).to  receive(:negate) { @p33 }
    allow(@p33).to receive(:negate) { @p3  }
    @p4  = instance_double("Arg2MOMDP::Predicate", :to_s => "h(b)")
    @p44 = instance_double("Arg2MOMDP::Predicate", :to_s => "!h(b)")
    allow(@p4).to  receive(:negate) { @p44 }
    allow(@p44).to receive(:negate) { @p4  }
    @a1  = instance_double("Alternative", :probability => 1, :to_s => "1.0: -a(a)",
                           :modifiers => [instance_double("Modifier", :type => :rem, :predicate => @p1, :to_s => "-#{@p1}")])
    @a2  = instance_double("Alternative", :probability => 0.5, :to_s => "0.5: +a(a) & .-h(b)",
                  :modifiers => [instance_double("Modifier", :type => :add, :predicate => @p1, :to_s => "+#{@p1}"),
                                 instance_double("Modifier", :type => :rem, :predicate => @p4, :to_s => ".-#{@p4}")])
    @a3  = instance_double("Alternative", :probability => 0.5, :to_s => "0.5: +e(a,b) & +a(b)",
                  :modifiers => [instance_double("Modifier", :type => :add, :predicate => @p2, :to_s => "+#{@p2}"),
                                 instance_double("Modifier", :type => :add, :predicate => @p3, :to_s => "+#{@p3}")])
  end

  it "raises an error if the sum of probabilities is not 1.0 with one alternative" do
    expect {Aptimizer::Rule.new([@p1], [@a2])}.to raise_error
  end

  it "raises an error if the sum of probabilities is not 1.0 with several alternatives" do
    expect {Aptimizer::Rule.new([@p1], [@a1, @a2])}.to raise_error
  end

  it "does not raise an error if the sum of probabilities is 1.0 with one alternatives" do
    expect {Aptimizer::Rule.new([@p1], [@a1])}.to_not raise_error
  end

  it "does not raise an error if the sum of probabilities is 1.0 with several alternatives" do
    expect {Aptimizer::Rule.new([@p11], [@a2, @a3])}.to_not raise_error
  end

  it "raises an error if there are contradictory premises" do
    expect {Aptimizer::Rule.new([@p1], [@a2, @a3])}.to raise_error
  end

  it "displays properly" do
    r  = Aptimizer::Rule.new([@p11,@p22], [@a2, @a3])
    expect(r.to_s).to eq("!a(a) & !e(a,b) & h(b) & !a(b) => 0.5: +a(a) & .-h(b) | 0.5: +e(a,b) & +a(b)")
  end
end