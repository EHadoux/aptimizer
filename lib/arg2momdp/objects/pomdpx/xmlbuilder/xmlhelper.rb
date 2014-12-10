module Arg2MOMDP
  module POMDPX
    module Helpers
      def build_cond_prob(xml, var, parent, *instances)
        xml.CondProb {
          xml.Var var
          xml.Parent parent
          xml.Parameter(:type => "TBL") {
            instances.each_slice(2) do |i, p|
              xml.Entry {
                xml.Instance i
                xml.ProbTable p
              }
            end
          }
        }
      end

      # Transforms a predicate to a string representation COMPATIBLE WITH POMDPX.
      #
      # @param pred [Predicate] The predicate to convert
      # @param suffix [String] Suffix to apply to the name (default "1")
      #
      # @return [String] The string representation
      def convert_string(pred, suffix=1)
        case pred.type
          when :atk then "#{pred.argument1}_#{pred.argument2}"
          when :priv then "#{pred.argument1}#{suffix}"
          when :pub then "#{pred.argument1}p"
        end
      end
    end
  end
end