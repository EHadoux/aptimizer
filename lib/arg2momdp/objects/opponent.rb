module Arg2MOMDP
  class Opponent
    attr_reader :rules, :flags
    attr_accessor :arguments

    # Constructs the opponent.
    #
    # @param arguments [Array<String>] The list of arguments
    # @param rules [Array<Rule>] The list of rules
    #
    # @raise [Error] if two or more {Rule}s share the same premises set
    def initialize(arguments, rules)
      @arguments = arguments
      @rules     = rules
      @flags     = []
      extract_flags
      @rules.each do |r|
        r.premises.each {|p| p.change_owner(2)}
        r.alternatives.each {|a| a.modifiers.each {|m| m.predicate.change_owner(2)}}
      end
      check_rules
    end

    # Extracts flags number in order to select alternatives when transitioning.
    def extract_flags
      @flags.clear
      rules.each_with_index do |r, i|
        @flags << i unless r.alternatives.size == 1
      end
    end

    private

    def check_rules
      0.upto(@rules.size-2) do |r_i|
        set = Set.new(@rules[r_i].premises)
        (r_i+1).upto(@rules.size-1) do |other_r_i|
          other_set = Set.new(@rules[other_r_i].premises)
          raise "Several rules cannot have the exact same premises: r#{r_i} and r#{other_r_i}" if set == other_set
        end
      end
    end
  end
end
