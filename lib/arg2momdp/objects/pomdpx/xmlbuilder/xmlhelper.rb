module Arg2MOMDP
  module POMDPX
    module Helpers
      # Transforms a predicate to a string representation COMPATIBLE WITH POMDPX.
      #
      # @param pred [Predicate] The predicate to convert
      #
      # @return [String] The string representation
      def convert_string(pred)
        case pred.type
          when :atk then "#{pred.argument1}_#{pred.argument2}"
          when :priv then "#{pred.argument1}#{pred.owner}"
          when :pub then "#{pred.argument1}p"
        end
      end
    end
  end
end