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

      # Merges all the UNSIDED premisses of the rules set in parameter that modify the predicate in parameter.
      #
      # @param rules [Array<Rule>] The rules to merge the UNSIDED premisses from
      # @param pred [Predicate] The predicate that is modified
      #
      # @return [Set<Predicate>, Array<Fixnum>] The set of merged premisses and the indexes of the rules modifying
      def cross_rules_premisses_with_index(rules, pred)
        set            = Set.new
        rule_index_arr = []
        rules.each_with_index do |r, i|
          if r.modifies?(pred)
            set.merge(r.premisses.map {|p| p.unsided})
            rule_index_arr << i
          end
        end
        return [set, rule_index_arr]
      end
    end
  end
end