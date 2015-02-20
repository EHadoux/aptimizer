module Aptimizer
  class Rule
    attr_reader :premises, :alternatives

    # Constructs a rule.
    #
    # @params premises [Array<Predicate>] The list of premises
    # @params alternatives [Array<Alternative>] The list of the possible alternatives if the rule is fired
    #
    # @raise [Error] if the sum of the probabilities of the alternatives is not 1
    def initialize(premises, alternatives)
      @premises     = premises
      @alternatives = alternatives

      if (sum = @alternatives.reduce(0) {|sum, c| sum + c.probability}) != 1.0
        raise "Sum of alternatives probabilities != 1.0: sum = #{sum}"
      end
    end

    # Returns a readable version of the rule.
    #
    # return [String] A String representation of the rule
    def to_s
      "#{@premises.join(" & ")} => #{@alternatives.join(" | ")}"
    end

    def compatible?(premises)
      premises.none?{ |p| @premises.include?(p.negate) }
    end

    def modifiers
      alternatives.map{|a| a.modifiers}.flatten
    end
  end
end
