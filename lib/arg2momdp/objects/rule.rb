module Arg2MOMDP
  class Rule
    attr_reader :premisses, :alternatives

    # Constructs a rule.
    #
    # @params premisses [Array<Predicate>] The list of premisses
    # @params alternatives [Array<Alternative>] The list of the possible alternatives if the rule is fired
    #
    # @raise [Error] if the sum of the probabilities of the alternatives is not 1
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

    # Returns whether this rule modifies the predicate in parameter or not.
    #
    # @param pred [Predicate] The predicate to test if modified
    # @return [Boolean] true if the rule modifies, false otherwise
    def modifies?(pred)
      @alternatives.any? {|a| a.modifies?(pred)}
    end

    # Expands all the implicit premisses, i.e, the negative of the modified predicates.
    # The rules are modified.
    def expand_premisses!
      set = Set.new
      set.merge(r.premisses)
      @alternatives.each do |alt|
        alt.modifiers.each do |mod|
          pred = (mod.type == :add) ? mod.predicate.negate : mod.predicate
          raise "Cannot add contradictory premisse #{pred} in rule #{rule}" if set.include?(pred.negate)
          set.add(pred)
        end
      end
      @premisses = set.to_a
    end
  end
end
