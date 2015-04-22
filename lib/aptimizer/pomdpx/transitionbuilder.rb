module Aptimizer
  module POMDPX
    class TransitionBuilder
      extend Helpers
      class << self
        # Need to optimize all those methods as several things are evaluated multiple times (like compatibility).
        # In a further version obviously.

        def build_transitions(xml, pomdp)
          #build_flags_transitions(xml, pomdp.opponent)
          modified_by = get_modifying_rules(pomdp.agent, pomdp.opponent)
          build_non_modified_predicates(xml, pomdp, modified_by)
          build_agent_private_transitions(xml, pomdp.agent, modified_by)
          build_public_argument_transitions(xml, pomdp.agent, pomdp.opponent, modified_by)
        end

        #def build_flags_transitions(xml, opponent)
        #  opponent.flags.each do |f|
        #    name    = "_nr#{f+1}"
        #    parents = "action"
        #    state   = "* -"
        #    prob    = opponent.rules[f].alternatives.map(&:probability).join(" ")
        #    build_cond_prob(xml, name, parents, state, prob)
        #  end
        #end

        def build_agent_private_transitions(xml, agent, modification_hash)
          private_args_selector = lambda {|p| p[0].type == :priv && p[0].owner == 1 && !p[1][0].empty? }
          modification_hash.lazy.select(&private_args_selector).each do |pred, actions_arr|
            build_agent_side_transitions(xml, agent, pred, actions_arr[0])
            actions_arr[0] = []
            modification_hash[pred] = actions_arr
          end
        end

        def build_agent_side_transitions(xml, agent, predicate, modifying_actions)
          prem_set = Set.new
          prem_set.add(predicate.unsided)
          modifying_actions.each do |act_i, _|
            prem_set.merge(agent.actions[act_i].premises.map(&:unsided))
          end
          premisses   = prem_set.to_a
          transitions = [] << "* - " + ("* " * (premisses.size - 1)) + "-" << "identity" << nil
          modifying_actions.each do |act_i, mod|
            instance  = [agent.action_names[act_i]] + (["*"] * premisses.size) + ["-"]
            agent.actions[act_i].premises.each do |prem|
              instance[premisses.find_index(prem.unsided)+1] = prem.positive ? "s1" : "s0"
            end
            transitions << instance.join(" ") << (mod == :add ? "0 1.0" : "1.0 0") << nil
          end
          name     = "n#{convert_string(predicate)}"
          prem_str = premisses.map(&method(:convert_string)).join(" ")
          parents  = "action " + prem_str
          build_cond_prob(xml, name, parents, *transitions)
        end

        def build_public_argument_transitions(xml, agent, opponent, modification_hash)
          public_or_atks = lambda {|p| p[0].type == :pub || p[0].type == :atk}
          modification_hash.lazy.select(&public_or_atks).each do |pred, modif_arrays|
            if modif_arrays[1].empty? && !modif_arrays[0].empty? # No modification of the predicate by the opponent
              build_agent_side_transitions(xml, agent, pred, modif_arrays[0])
            else
              flags_set  = Set.new
              pairs      = Array.new(agent.actions.size) { [] }
              prem_set   = Set.new
              prem_set.add(pred.unsided)
              agent.actions.each_with_index do |act, act_i|
                prem_set.merge(act.premises.map(&:unsided))
                premisses = prem_set.to_a
                instance  = [agent.action_names[act_i]] + (["*"] * premisses.size) + ["-"]
                act.alternatives[0].modifiers.each do |mod|
                  index = premisses.find_index(mod.predicate)
                  instance[index+1] = mod.type == :add ? "s1" : "s0" unless index.nil?
                end
                opponent.rules.each_with_index do |rule, rule_i|
                  if compatible?(rule, instance, premisses)
                    prem_set.merge(rule.premises.map(&:unsided))
                    pairs[act_i] << rule_i
                    flags_set.add(rule_i) if opponent.rules[rule_i].alternatives.size > 1
                  end
                end
              end
              premisses   = prem_set.to_a
              transitions = [] << "* - " + ("* " * (premisses.size - 1)) + ("* " * flags_set.size) + "-" << "identity" << nil
              pairs.each_with_index do |rules_i, act_i|
                instance    = (["*"] * (prem_set.size + 1)) + (flags_set.map{|i| "r#{i}"}) + ["-"]
                instance[0] = agent.action_names[act_i]
                instance[1] = "-"
                agent.actions[act_i].premises.each do |prem|
                  instance[premisses.find_index(prem.unsided)+1] = prem.positive ? "s1" : "s0"
                end
                modified_instance = Array.new(instance)
                agent.actions[act_i].alternatives[0].modifiers.each do |mod|
                  index = premisses.find_index(mod.predicate)
                  modified_instance[index+1] = mod.type == :add ? "s1" : "s0" unless index.nil?
                end
                [false, true].repeated_permutation(rules_i.size).sort_by { |p| p.count(true) }.each do |perm|
                  interm_state    = Array.new(instance)
                  modified_interm_state = Array.new(modified_instance)
                  cumulated_prems = Set.new(agent.actions[act_i].premises.map(&:unsided))
                  cumulated_prems.merge(agent.actions[act_i].alternatives[0].modifiers.map(&:predicate))
                  skip            = false
                  perm.each_with_index do |val, ind|
                    next unless val
                    if compatible?(opponent.rules[rules_i[ind]], modified_interm_state, premisses)
                      prem_to_loop = prem_set - cumulated_prems
                      rule_prem    = opponent.rules[rules_i[ind]].premises
                      rule_prem.each do |prem|
                        if prem_to_loop.include?(prem.unsided)
                          index = premisses.find_index(prem.unsided)+1
                          interm_state[index] = prem.positive ? "s1" : "s0"
                          modified_interm_state[index] = prem.positive ? "s1" : "s0"
                        end
                      end
                      cumulated_prems.merge(rule_prem.map(&:unsided))
                    else
                      skip = true
                      break
                    end
                  end
                  next if skip
                  alt_lists = flags_set.to_a.map do |f|
                    s = opponent.rules[f].alternatives.size
                    s.times.map{|i| "alt#{i+1}"} if perm[f]
                  end.compact
                  cross_flags = [""].product(*alt_lists)
                  cross_flags = [nil] if cross_flags.empty?
                  cross_flags.each do |f|
                    flags                   = Array.new(f)
                    mod_sides               = [[], [], []]
                    interm_state_with_flags = Array.new(interm_state)
                    unless flags.nil?
                      flags.shift
                      #flags.reverse_each.with_index { |flag, flag_i| interm_state_with_flags[-flag_i-2] = flag}
                    end

                    modified = false
                    rules_i.each_with_index do |rule_i, ind|
                      rule = opponent.rules[rule_i]
                      next unless perm[ind]
                      alt  = rule.alternatives.size > 1 ? (flags.shift[-1].to_i - 1) : 0
                      index = interm_state_with_flags.find_index("r#{rule_i}")
                      interm_state_with_flags[index] = "alt#{alt+1}" if rule.alternatives.size > 1
                      if rule.alternatives[alt].modifies?(pred)
                        modified = true
                        mod = rule.alternatives[alt].modifiers.select { |m| m.predicate == pred }
                        raise "Bug" if mod.size != 1
                        mod = mod[0]
                        mod_sides[mod.type == :rem ? 0 : 1] << rule_i
                      else
                        mod_sides[2] << rule_i
                      end
                    end
                    unless modified
                      mod_sides = [[], [], []]
                      if agent.actions[act_i].alternatives[0].modifies?(pred)
                        modified = true
                        mod = agent.actions[act_i].alternatives[0].modifiers.select { |m| m.predicate == pred }
                        raise "Bug" if mod.size != 1
                        mod = mod[0]
                        mod_sides[mod.type == :rem ? 0 : 1] = act_i
                      else
                        mod_sides[2] = act_i
                      end
                    end
                    next unless modified

                    pred_instance_value = interm_state_with_flags[1]
                    if pred_instance_value == "-"
                      probas    = Array.new(4)
                      probas[0] = mod_sides[0].size + mod_sides[2].size
                      probas[1] = mod_sides[1].size
                      probas[2] = mod_sides[0].size
                      probas[3] = mod_sides[1].size + mod_sides[2].size
                      probas.map!{ |p| p.to_f / mod_sides.lazy.map(&:size).reduce(:+)}
                      probas_str = probas.join(" ")
                    else
                      mod_sides[pred_instance_value[1].to_i] += mod_sides[2]
                      sides_sum  = mod_sides[0].size + mod_sides[1].size
                      s0_proba   = mod_sides[0].size.to_f / sides_sum
                      s1_proba   = mod_sides[1].size.to_f / sides_sum
                      probas_str = "#{s0_proba} #{s1_proba}"
                    end
                    interm_state_with_flags.map!{|i| i.start_with?("r") ? "*" : i}
                    transitions << interm_state_with_flags.join(" ") << probas_str << rules_i.map{|r| "r#{r+1}=#{perm[r] ? "1" : "0"}"}.join(" ")
                  end
                end
              end
              prem_str = premisses.map {|p| convert_string(p)}
              build_cond_prob(xml, "n#{convert_string(pred)}", "action " + prem_str.join(" ") + " " + flags_set.to_a.reverse.map{|f| "_r#{f+1}"}.join(" "), *transitions)
            end
          end
        end

        def build_non_modified_predicates(xml, pomdpx, modification_hash)
          private_init   = lambda { |arg, owner| Predicate.new(:priv, arg, owner: owner) }
          public_init    = lambda { |arg, _| Predicate.new(:pub, arg) }
          atk_init       = lambda { |arg, _| arg }
          private_empty  = lambda { |pred, owner| modification_hash.has_key?(pred) && !modification_hash[pred][owner-1].empty? }
          public_empty   = lambda { |pred, _| modification_hash.has_key?(pred) }
          build = lambda do |set, owner, init, tester|
            set.each do |arg|
              pred     = init.call(arg, owner)
              str_name = convert_string(pred)
              parents  = "action #{str_name}"
              state    = "* - -"
              prob     = "identity"
              build_cond_prob(xml, "n#{str_name}", parents, state, prob) unless tester.call(pred, owner)
            end
          end

          build.call(pomdpx.agent.arguments, 1, private_init, private_empty)
          build.call(pomdpx.opponent.arguments, 2, private_init, private_empty)
          build.call(pomdpx.public_space.arguments, 0, public_init, public_empty)
          #build.call(pomdpx.public_space.attacks, 0, :itself.to_proc, public_empty)
          build.call(pomdpx.public_space.attacks, 0, atk_init, public_empty)
        end
      end

      private_class_method :build_agent_private_transitions, #:build_flags_transitions,
                           :build_public_argument_transitions, :build_non_modified_predicates,
                           :build_agent_side_transitions
    end
  end
end
