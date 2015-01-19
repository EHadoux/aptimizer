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

      def compatible?(rule, instance, prem_arr)
        premisses = []
        prem_arr[1..-1].each_with_index do |prem, prem_i|
          if instance[prem_i] == "s0"
            premisses << prem.negate
          elsif instance[prem_i] == "s1"
            premisses << prem.clone
          end
        end
        return rule.compatible?(premisses)
      end

      # For each predicate, gives which actions and rules modify it
      def get_modifying_rules(agent, opponent)
        modified_by = Hash.new { [[],[]] }
        track = lambda do |set, index|
          set.each_with_index do |rule, rule_i|
            rule.alternatives.each do |alt|
              alt.modifiers.each do |mod|
                arr = modified_by[mod.predicate]
                arr[index] << [rule_i, mod.type]
                modified_by[mod.predicate] = arr
              end
            end
          end
        end
        track.call(agent.actions, 0)
        track.call(opponent.rules, 1)
        return modified_by
      end

      def get_goal_full_set(agent, public_space)
        set      = Set.new
        set.merge(agent.goals)
        loop do
          modified = false
          to_add = Set.new
          set.each do |pred|
            public_space.attacks.each do |atk|
              if atk.argument2 == pred.argument1 && !set.include?(atk)
                to_add.add(atk)
                modified = true
              end
            end
          end
          set.merge(to_add)
          break unless modified
        end
        return set.to_a
      end

      def evaluate_goal_compliance(goals_hash)
        atk_arr, pred_arr = goals_hash.partition{|p| p[0].type == :atk}
        value_hash        = Hash.new
        pred_arr.each do |pred, value|
          return false if pred.positive && !value
          next unless pred.positive || value
          is_true?(pred, atk_arr, value_hash)
        end
        return true
      end

      def is_true?(predicate, atk_arr, value_hash)
        return value_hash[predicate] if value_hash.include?(predicate)
        atk_arr.lazy.select{|atk| atk[0].argument2 == predicate.argument1}.each do |atk|
          next unless atk[1]
          if is_true?(atk[0], atk_arr, value_hash)
            value_hash[predicate] = false
            return false
          end
        end
        value_hash[predicate] = true
        return true
      end


      def build_cond_prob(xml, var, parent, *instances)
        xml.CondProb {
          xml.Var var
          xml.Parent parent
          xml.Parameter(:type => "TBL") {
            instances.each_slice(3) do |i, p, c|
              xml.Entry {
                xml.comment c unless c.nil?
                xml.Instance i
                xml.ProbTable p
              }
            end
          }
        }
      end
    end
  end
end