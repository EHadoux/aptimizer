module Arg2MOMDP
  class Alternative
    attr_reader :modifiers
    attr_accessor :probability

    # Constructs an alternative for a {Rule}.
    #
    # @param modifiers [Array<Modifier>] An array of modifiers
    # @param p [Fixnum] The probability of this alternative
    def initialize(modifiers, p=1.0)
      @probability = p
      @modifiers   = modifiers
    end

    # Returns a readable version of the alternative.
    #
    # return [String] A String representation of the alternative
    def to_s
      "#{@probability}: #{@modifiers.join(" & ")}"
    end

    # Returns whether this alternative can modify the predicate in parameter or not.
    #
    # @param pred [Predicate] The predicate to test if modified
    # @return [Boolean] true if the alternative modifies, false otherwise
    def modifies?(pred)
      @modifiers.any? {|m| m.predicate == pred}
    end
  end
end
