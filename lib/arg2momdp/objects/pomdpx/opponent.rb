module Arg2MOMDP
  module POMDPX
    class Opponent
      attr_reader :arguments, :rules, :flags

      # Constructs the opponent.
      #
      # @param arguments [Array<String>] The list of arguments
      # @param rules [Array<Rule>] The list of rules
      def initialize(arguments, rules)
        @arguments = arguments
        @rules     = rules
        @flags     = []
        extract_flags!
      end

      private

      # Extracts flags number in order to select alternatives when transitioning.
      def extract_flags!
        rules.each_with_index do |r, i|
          @flags << i unless r.alternatives.size == 1
        end
      end
    end
  end
end