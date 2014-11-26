module Arg2MOMDP
  module POMDPX
    class Opponent
      attr_reader :arguments, :rules, :flags

      def initialize(arguments, rules)
        @arguments = arguments
        @rules     = rules
        @flags     = []
        cut_flags
      end

      private

      def cut_flags
        rules.each_with_index do |r, i|
          @flags << i unless r.alternatives.size == 1
        end
      end
    end
  end
end