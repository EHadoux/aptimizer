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
        prem_arr.drop(1).each_with_index do |prem, prem_i|
          next unless rule.premises.map(&:unsided).include?(prem)
          if instance[prem_i+2] == "s0"
            premisses << prem.negate
          elsif instance[prem_i+2] == "s1"
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
        arg_set  = Set.new
        set.merge(agent.goals)
        arg_set.merge(agent.goals)
        loop do
          modified    = false
          atk_to_add  = Set.new
          args_to_add = Set.new
          set.each do |pred|
            public_space.backup_attacks.each do |atk|
              if atk.argument2 == pred.argument1 && !set.include?(atk) && public_space.arguments.include?(atk.argument1)
                atk_to_add.add(atk)
                args_to_add.add(Predicate.new(:pub, atk.argument1))
                modified = true
              end
            end
          end
          set.merge(atk_to_add)
          arg_set.merge(args_to_add)
          break unless modified
        end
        public_space.direct_relevance ? arg_set.to_a : set.to_a
      end

      def evaluate_goal_compliance_dr(goals_hash, agent, public_space)
        atk_arr, pred_arr = goals_hash.partition{|p| !agent.goals.include? p[0]}
        value_hash        = Hash.new
        pred_arr.each do |pred, value|
          return false if pred.positive && !value
          next unless pred.positive || value
          stack = [pred]
          if is_true_dr?(pred, atk_arr, value_hash, public_space, stack)
            return false unless pred.positive
          else
            return false if pred.positive
          end
        end
        return true
      end

      def evaluate_goal_compliance(goals_hash)
        atk_arr, pred_arr = goals_hash.partition{|p| p[0].type == :atk}
        value_hash        = Hash.new
        pred_arr.each do |pred, value|
          return false if pred.positive && !value
          next unless pred.positive || value
          stack = [pred]
          if is_true?(pred, atk_arr, value_hash, stack)
            return false unless pred.positive
          else
            return false if pred.positive
          end
        end
        return true
      end

      def is_true_dr?(predicate, atk_arr, value_hash, public_space, stack)
        return value_hash[predicate] if value_hash.include?(predicate)
        atk_arr.lazy.select{|atk| public_space.backup_attacks.include?(Predicate.new(:atk, atk[0].argument1, arg2:predicate.argument1)) && stack.none?{|p| atk[0].argument1 != p.argument1}}.each do |atk|
          next unless atk[1]
          stack.unshift atk[0]
          if is_true_dr?(atk[0], atk_arr, value_hash, public_space, stack)
            stack.shift
            value_hash[predicate] = false
            return false
          end
        end
        value_hash[predicate] = true
        stack.shift
        return true
      end

      def is_true?(predicate, atk_arr, value_hash, stack)
        return value_hash[predicate] if value_hash.include?(predicate)
        atk_arr.lazy.select{|atk| (atk[0].argument2 == predicate.argument1) && stack.none?{|p| atk[0].argument1 != p.argument1 && atk[0].argument2 != p.argument2}}.each do |atk|
          next unless atk[1]
          stack.unshift atk[0]
          res = is_true?(atk[0], atk_arr, value_hash, stack)
          if res
            stack.shift
            value_hash[predicate] = false
            return false
          end
        end
        stack.shift
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