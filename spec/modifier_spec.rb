require "aptimizer"

RSpec.describe Aptimizer::Modifier do
  it "raises an error if the scope is unknown" do
    expect {Aptimizer::Modifier.new(nil, :unknown, nil)}.to raise_error
  end

  it "raises an error if the type is unknown" do
    expect {Aptimizer::Modifier.new(:unknown, nil, nil)}.to raise_error
  end

  it "raises an error if the predicate is negative" do
    p = instance_double("Predicate", :positive => false)
    expect {Aptimizer::Modifier.new(:add, :pub, p)}.to raise_error
  end

  context "Public" do
    before(:each) do
      @pred_pub = instance_double("Predicate", :type => :pub, :to_s => "a(a)", :positive => true)
    end

    it "raises an error if the scope is private and the predicate public" do
      expect {Aptimizer::Modifier.new(:add, :priv, @pred_pub)}.to raise_error
    end

    it "displays properly" do
      m = Aptimizer::Modifier.new(:add, :pub, @pred_pub)
      expect(m.to_s).to eq("+#{@pred_pub}")
      m = Aptimizer::Modifier.new(:rem, :pub, @pred_pub)
      expect(m.to_s).to eq("-#{@pred_pub}")
    end
  end

  context "Private" do
    before(:each) do
      @pred_priv = instance_double("Predicate", :type => :priv, :to_s => "h(a)", :positive => true)
      @pred_atk  = instance_double("Predicate", :type => :atk, :to_s => "e(a, b)", :positive => true)
    end

    it "raises an error if the scope is public and the predicate private" do
      expect {Aptimizer::Modifier.new(:add, :pub, @pred_priv)}.to raise_error
    end

    it "raises an error if the scope is private and the predicate is an attack" do
      expect {Aptimizer::Modifier.new(:add, :priv, @pred_atk)}.to raise_error
    end

    it "displays properly" do
      m = Aptimizer::Modifier.new(:add, :priv, @pred_priv)
      expect(m.to_s).to eq(".+#{@pred_priv}")
      m = Aptimizer::Modifier.new(:rem, :priv, @pred_priv)
      expect(m.to_s).to eq(".-#{@pred_priv}")
    end
  end
end
