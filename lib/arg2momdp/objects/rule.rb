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

      expand_premisses
    end

    # Returns a readable version of the rule.
    #
    # return [String] A String representation of the rule
    def to_s
      "#{@premisses.join(" & ")} => #{@alternatives.join(" | ")}"
    end

    def compatible?(premisses)
      return premisses.none?{ |p| @premisses.include?(p.negate) }
    end

    private

    # Expands all the implicit premisses, i.e, the negation of the modified predicates.
    # The rule is modified.
    def expand_premisses
      set = Set.new
      set.merge(@premisses)
      @alternatives.each do |alt|
        alt.modifiers.each do |mod|
          pred = (mod.type == :add) ? mod.predicate.negate : mod.predicate
          raise "Cannot add contradictory premisse #{pred}" if set.include?(pred.negate)
          set.add(pred)
        end
      end
      @premisses = set.to_a
    end
  end
end
