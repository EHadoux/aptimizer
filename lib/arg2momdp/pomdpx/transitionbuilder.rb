module Arg2MOMDP
  module POMDPX
    class TransitionBuilder
      extend Helpers
      class << self
        # Need to optimize all those methods as several things are evaluated multiple times (like compatibility).
        # In a further version obviously.

        def build_transitions(xml, pomdp)
          build_flags_transitions(xml, pomdp.opponent)
          modified_by = get_modifying_rules(pomdp.agent, pomdp.opponent)
          build_non_modified_predicates(xml, pomdp, modified_by)
          build_agent_private_transitions(xml, pomdp.agent, modified_by)
          build_public_argument_transitions(xml, pomdp.agent, pomdp.opponent, modified_by)
        end

        def build_flags_transitions(xml, opponent)
          opponent.flags.each do |f|
            build_cond_prob(xml, "_nr#{f+1}", "action", "* -", opponent.rules[f].alternatives.map(&:probability).join(" "))
          end
        end

        def build_agent_private_transitions(xml, agent, modification_hash)
          modification_hash.lazy.select {|p| p[0].type == :priv && p[0].owner == 1 && !p[1][0].empty? }.each do |pred, actions_arr|
            build_agent_side_transitions(xml, agent, pred, actions_arr[0])
            actions_arr[0] = []
            modification_hash[pred] = actions_arr
          end
        end

        def build_agent_side_transitions(xml, agent, predicate, modifying_actions)
          prem_set    = Set.new
          prem_set.add(predicate.unsided)
          modifying_actions.each do |act_i, _|
            prem_set.merge(agent.actions[act_i].premises.map(&:unsided))
          end
          transitions = []
          premisses   = prem_set.to_a
          transitions << "* - " + ("* " * (premisses.size - 1)) + "-" << "identity" << nil
          modifying_actions.each do |act_i, mod|
            instance  = [agent.action_names[act_i]] + (["*"] * premisses.size) + ["-"]
            agent.actions[act_i].premises.each do |prem|
              instance[premisses.find_index(prem.unsided)+1] = prem.positive ? "s1" : "s0"
            end
            transitions << instance.join(" ") << (mod == :add ? "0 1.0" : "1.0 0") << nil
          end
          prem_str = premisses.map {|p| convert_string(p)}
          build_cond_prob(xml, "n#{convert_string(predicate)}",
                          "action " + prem_str.join(" "), *transitions)
        end

        def build_public_argument_transitions(xml, agent, opponent, modification_hash)
          modification_hash.lazy.select {|p| p[0].type == :pub || p[0].type == :atk }.each do |pred, modif_arrays|
            if modif_arrays[1].empty? && !modif_arrays[0].empty?
              build_agent_side_transitions(xml, agent, pred, modif_arrays[0])
            else
              flags_set  = Set.new
              pairs      = Array.new(agent.actions.size) { Array.new }
              prem_set   = Set.new
              prem_set.add(pred.unsided)
              agent.actions.each_with_index do |act, act_i|
                prem_set.merge(act.premises.map(&:unsided))
                premisses    = prem_set.to_a
                instance     = [agent.action_names[act_i]] + (["*"] * premisses.size) + ["-"]
                interm_state = Array.new(instance)
                act.alternatives[0].modifiers.each do |mod|
                  interm_state[premisses.find_index(mod.predicate)+1] = mod.type == :add ? "s1" : "s0"
                end
                opponent.rules.each_with_index do |rule, rule_i|
                  if compatible?(rule, interm_state, premisses)
                    prem_set.merge(rule.premises.map(&:unsided))
                    pairs[act_i] << rule_i
                    flags_set.add(rule_i) if opponent.rules[rule_i].alternatives.size > 1
                  end
                end
              end
              alt_lists   = flags_set.to_a.map do |f|
                s = opponent.rules[f].alternatives.size
                s.times.map{|i| "alt#{i+1}"} if s > 1
              end.compact
              premisses   = prem_set.to_a
              instance    = (["*"] * (prem_set.size + 1)) + (["*"] * flags_set.size) + ["-"]
              transitions = []
              transitions << "* - " + ("* " * (premisses.size - 1)) + ("* " * flags_set.size) + "-" << "identity" << nil
              pairs.each_with_index do |rules_i, act_i|
                instance[0]  = agent.action_names[act_i]
                agent.actions[act_i].premises.each do |prem|
                  instance[premisses.find_index(prem.unsided)+1] = prem.positive ? "s1" : "s0"
                end
                agent.actions[act_i].alternatives[0].modifiers.each do |mod|
                  instance[premisses.find_index(mod.predicate)+1] = mod.type == :add ? "s1" : "s0"
                end
                cross_flags  = [""].product(*alt_lists)
                cross_flags  = [nil] if cross_flags.empty?
                [false, true].repeated_permutation(rules_i.size).sort_by { |p| p.count(true) }.drop(1).each do |perm|
                  interm_state    = Array.new(instance)
                  cumulated_prems = Set.new(agent.actions[act_i].premises.map(&:unsided))
                  skip            = false
                  perm.each_with_index do |val, ind|
                    next unless val
                    if compatible?(opponent.rules[rules_i[ind]], interm_state, premisses)
                      prem_to_loop = prem_set - cumulated_prems
                      rule_prem    = opponent.rules[rules_i[ind]].premises
                      rule_prem.each do |prem|
                        interm_state[premisses.find_index(prem.unsided)+1] = prem.positive ? "s1" : "s0" if prem_to_loop.include?(prem.unsided)
                      end
                      cumulated_prems.merge(rule_prem.map(&:unsided))
                    else
                      skip = true
                      break
                    end
                  end
                  next if skip
                  cross_flags.each do |f|
                    flags                   = Array.new(f)
                    mod_sides               = [[], [], []]
                    interm_state_with_flags = Array.new(interm_state)
                    unless flags.nil?
                      flags.shift
                      flags.reverse_each.with_index { |flag, flag_i| interm_state_with_flags[-flag_i-2] = flag}
                    end
                    rules_i.each_with_index do |rule_i, ind|
                      rule = opponent.rules[rule_i]
                      alt = rule.alternatives.size > 1 ? (flags.shift[-1].to_i - 1) : 0
                      next unless perm[ind]
                      if rule.alternatives[alt].modifies?(pred)
                        mod = rule.alternatives[alt].modifiers.select { |m| m.predicate == pred }
                        raise "Bug" if mod.size != 1
                        mod = mod[0]
                        mod_sides[mod.type == :rem ? 0 : 1] << rule_i
                      else
                        mod_sides[2] << rule_i
                      end
                    end
                    next if mod_sides[0].empty? && mod_sides[1].empty?
                    s0_proba = mod_sides[0].size / (mod_sides[0].size + mod_sides[1].size)
                    s1_proba = mod_sides[1].size / (mod_sides[0].size + mod_sides[1].size)
                    transitions << interm_state_with_flags.join(" ") << "#{s0_proba} #{s1_proba}" << rules_i.map{|r| "r#{r+1}=#{perm[r] ? "1" : "0"}"}.join(" ")
                  end
                end
              end
              prem_str = premisses.map {|p| convert_string(p)}
              build_cond_prob(xml, "n#{convert_string(pred)}", "action " + prem_str.join(" ") + " " + flags_set.to_a.map{|f| "_r#{f+1}"}.join(" "), *transitions)
            end
          end
        end

        def build_non_modified_predicates(xml, pomdpx, modification_hash)
          pomdpx.agent.arguments.each do |arg|
            pred     = Predicate.new(:priv, arg)
            str_name = convert_string(pred)
            build_cond_prob(xml, "n#{str_name}", "action #{str_name}", "* - -", "identity") unless modification_hash.has_key?(pred) && !modification_hash[pred][0].empty?
          end

          pomdpx.opponent.arguments.each do |arg|
            pred     = Predicate.new(:priv, arg, owner:2)
            str_name = convert_string(pred)
            build_cond_prob(xml, "n#{str_name}", "action #{str_name}", "* - -", "identity") unless modification_hash.has_key?(pred) && !modification_hash[pred][1].empty?
          end

          pomdpx.public_space.arguments.each do |arg|
            pred     = Predicate.new(:pub, arg)
            str_name = convert_string(pred)
            build_cond_prob(xml, "n#{str_name}", "action #{str_name}", "* - -", "identity") unless modification_hash.has_key?(pred)
          end

          pomdpx.public_space.attacks.each do |atk|
            str_name = convert_string(atk)
            build_cond_prob(xml, "n#{str_name}", "action #{str_name}", "* - -", "identity") unless modification_hash.has_key?(atk)
          end
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

      private_class_method :build_agent_private_transitions, :build_flags_transitions,
                           :build_public_argument_transitions, :build_non_modified_predicates,
                           :build_agent_side_transitions, :build_cond_prob
    end
  end
end
