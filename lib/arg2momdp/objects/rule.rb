module Arg2MOMDP
  class Rule
    attr_reader :premisses, :alternatives

    def initialize(premisses, alternatives)
      @premisses   = premisses
      @alternatives = alternatives

      if (sum = @alternatives.reduce(0) {|sum, c| sum + c.probability}) != 1.0
        raise "Sum of alternatives probabilities != 1.0: sum = #{sum}"
      end
    end

    def to_s
      "#{@premisses.join(" & ")} => #{@alternatives.join(" | ")}"
    end

    def modifies?(type, arg1, arg2=nil)
      @alternatives.any? {|a| a.modifies?(type, arg1, arg2)}
    end
  end
end
