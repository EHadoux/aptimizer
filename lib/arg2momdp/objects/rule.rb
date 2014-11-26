module Arg2MOMDP
  class Rule
    attr_accessor :premisses
    attr_reader :alternatives

    # Constructs a rule.
    #
    # @params premisses [Array<Predicate>] The list of premisses
    # @params alternatives [Array<Alternative>] The list of the possible alternatives if the rule is fired
    def initialize(premisses, alternatives)
      @premisses   = premisses
      @alternatives = alternatives

      if (sum = @alternatives.reduce(0) {|sum, c| sum + c.probability}) != 1.0
        raise "Sum of alternatives probabilities != 1.0: sum = #{sum}"
      end
    end

    # Returns a readable version of the rule.
    #
    # return [String] A String representation of the rule
    def to_s
      "#{@premisses.join(" & ")} => #{@alternatives.join(" | ")}"
    end

    # Returns whether this rule can modify the predicate in parameter or not.
    #
    # @param pred [Predicate] The predicate to test if modified
    # @return [Boolean] true if the rule modifies, false otherwise
    def modifies?(pred)
      @alternatives.any? {|a| a.modifies?(pred)}
    end
  end
end
