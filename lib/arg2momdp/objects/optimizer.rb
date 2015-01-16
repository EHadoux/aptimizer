module Arg2MOMDP
  class Optimizer
    class << self
      def optimize(pomdp, *optimizations)
        flags_list = [:agent_args, :opp_args, :initial, :attacks, :dominated]
        f = (optimizations - flags_list) and (raise "Unknown flags :#{f}" unless f.empty?)
        optimizations = flags_list if optimizations.empty?
        optimizations += [:agent_args, :opp_args] if (optimizations.include?(:initial) || optimizations.include?(:dominated))
        remove_useless_args(pomdp.agent) if optimizations.include?(:agent_args)
        remove_useless_args(pomdp.opponent) if optimizations.include?(:opp_args)
        remove_attacks(pomdp) if optimizations.include?(:attacks)
        remove_dominated(pomdp) if optimizations.include?(:dominated)
        optimize_initial(pomdp.agent, pomdp.opponent, pomdp.public_space) if optimizations.include?(:initial)
      end

      # Removes arguments not involved in any premise or modifier
      #
      # @param agent [Agent, Opponent] The agent or opponent to optimize
      def remove_useless_args(agent)
        args = Set.new
        agent.rules.each do |rule|
          args.merge(rule.premises.select{|p| p.type == :priv}.map(&:argument1)) # Merge all premises
          rule.alternatives.each do |alt|
            args.merge(alt.modifiers.select{|m| m.predicate.type == :priv}.map{|m| m.predicate.argument1}) # Merge all modifiers
          end
        end
        puts "Arguments removed: #{agent.arguments.size - args.size}"
        agent.arguments = args.to_a # Arguments not involved in any premise or modifier are left over
      end

      # Removes attacks from the rules
      # It is up to the user to know if this makes sense for this problem
      def remove_attacks(pomdp)
        pomdp.public_space.attacks.clear
        remover = lambda do |ag|
          ag.rules.each do |rule|
            rule.premises.delete_if {|p| p.type == :atk}
            rule.alternatives.each do |alt|
              alt.modifiers.delete_if {|m| m.predicate.type == :atk}
            end
          end
        end
        remover.call(pomdp.agent)
        remover.call(pomdp.opponent)
        puts "Attacks removed: #{pomdp.public_space.backup_attacks.size}"
      end

      # Removes arguments of agent 1 that can never be defended
      def remove_dominated(pomdp)
        graph = AtkGraph::Graph.new
        pomdp.public_space.backup_attacks.each do |atk| # Creates the graph
          arg1 = atk.argument1
          arg2 = atk.argument2
          v1   = AtkGraph::Vertex.new(arg1, pomdp.agent.arguments.include?(arg1) ? :agent : :opponent)
          v2   = AtkGraph::Vertex.new(arg2, pomdp.agent.arguments.include?(arg2) ? :agent : :opponent)
          graph.add_atk(v1, v2)
        end

        loop do
          to_rem = graph.vertices.select {|v| v.dominated? && v.owner == :agent} # Gets all dominated arguments of agent 1
          break if to_rem.empty?
          to_rem.each do |vertex|
            pomdp.agent.arguments.delete(vertex.value)
            puts "Argument #{vertex.value} removed"
            pomdp.agent.actions.reverse.each_with_index do |act, act_i|
              act.alternatives[0].modifiers.delete_if {|m| m.predicate.argument1 == vertex.value} # Removes modifiers
              if act.alternatives[0].modifiers.empty? # If no more, removes the rule, otherwise, removes premises
                pomdp.agent.actions.delete_at(-(act_i+1))
                name = pomdp.agent.action_names.delete_at(-(act_i+1))
                puts "Action #{name} removed"
              else
                act.premises.delete_if {|p| p.argument1 == vertex.value}
              end
            end
            graph.vertices.delete(vertex)
          end
        end
      end

      def optimize_initial(agent, opponent, public_space)
        optimize_initial_agent(agent)
        optimize_initial_public(agent, opponent, public_space)
      end

      def optimize_initial_agent(agent)
        args_to_rem = Set.new
        old_set     = nil
        loop do
          agent.arguments.each do |arg|
            args_to_rem << Predicate.new(:priv, arg)
            agent.actions.each do |act|
              act.alternatives[0].modifiers.select{|m| m.predicate.type == :priv}.each do |mod|
                args_to_rem.delete(mod.predicate.unsided) if (mod.type == :rem) == agent.initial_state[mod.predicate.argument1]
              end
            end
          end
          break if args_to_rem.empty? || args_to_rem == old_set
          args_to_rem.each do |arg|
            agent.arguments.delete(arg.argument1)
            act_to_rem = []
            agent.actions.each_with_index do |act, act_i|
              if (index = act.premises.lazy.map(&:unsided).find_index(arg))
                if agent.initial_state[arg.argument1] == act.premises[index].positive
                  act.premises.delete_at(index)
                else
                  act_to_rem << act_i
                end
              end
            end
            act_to_rem.reverse_each do |act_i|
              agent.actions.delete_at(act_i)
              agent.action_names.delete_at(act_i)
            end
            puts "Rule(s) removed: #{act_to_rem.size}" unless act_to_rem.size == 0
          end
          old_set = Set.new(args_to_rem)
          args_to_rem.clear
        end
      end

      def optimize_initial_public(agent, opponent, public_space)
        args_to_rem = Set.new
        old_set     = nil
        tracker = lambda do |ag|
          ag.rules.each do |rule|
            rule.alternatives.each do |alt|
              alt.modifiers.select{|m| m.predicate.type == :pub}.each do |mod|
                args_to_rem.delete(mod.predicate.unsided) if (mod.type == :rem) == public_space.initial_state[mod.predicate.argument1]
              end
            end
          end
        end

        remover = lambda do |ag, arg|
          act_to_rem = []
          ag.rules.each_with_index do |act, act_i|
            if (index = act.premises.lazy.map(&:unsided).find_index(arg))
              if public_space.initial_state[arg.argument1] == act.premises[index].positive?
                act.premises.delete_at(index)
              else
                act_to_rem << act_i
              end
            end
          end
          act_to_rem.reverse_each do |act_i|
            ag.rules.delete_at(act_i)
            ag.action_names.delete_at(act_i) if ag.respond_to?(:action_names)
            ag.extract_flags if ag.respond_to?(:extract_flags)
          end
          puts "Rule(s) removed: #{act_to_rem.size}" unless act_to_rem.size == 0
        end

        loop do
          public_space.arguments.each do |arg|
            args_to_rem << Predicate.new(:pub, arg)
            tracker.call(agent)
            tracker.call(opponent)
          end
          break if args_to_rem.empty? || args_to_rem == old_set
          args_to_rem.each do |arg|
            public_space.arguments.delete(arg.argument1)
            remover.call(agent, arg)
            remover.call(opponent, arg)
          end
          old_set = Set.new(args_to_rem)
          args_to_rem.clear
        end
      end
    end

    private_class_method :remove_useless_args, :optimize_initial, :optimize_initial_agent, :remove_dominated, :remove_attacks
  end
end
