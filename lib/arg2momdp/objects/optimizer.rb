module Arg2MOMDP
  class Optimizer
    class << self
      def optimize(pomdp, *optimizations)
        flags_list = [:agent_args, :opp_args, :initial]
        f = (optimizations - flags_list) and (raise "Unknown flags :#{f}" unless f.empty?)
        optimizations = flags_list if optimizations.empty?
        optimizations += [:agent_args, :opp_args] if optimizations.include?(:initial)
        optimize_args(pomdp.agent) if optimizations.include?(:agent_args)
        optimize_args(pomdp.opponent) if optimizations.include?(:opp_args)
        optimize_initial(pomdp.agent, pomdp.opponent, pomdp.public_space) if optimizations.include?(:initial)
      end

      def optimize_args(agent)
        args = Set.new
        agent.rules.each do |rule|
          args.merge(rule.premises.select{|p| p.type == :priv}.map(&:argument1))
          rule.alternatives.each do |alt|
            args.merge(alt.modifiers.select{|m| m.predicate.type == :priv}.map{|m| m.predicate.argument1})
          end
        end
        puts "Arguments removed: #{agent.arguments.size - args.size}"
        agent.arguments = args.to_a
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
            puts "Rules removed: #{act_to_rem.size}" unless act_to_rem.size == 0
          end
          old_set = Set.new(args_to_rem)
          args_to_rem.clear
        end
      end

      def optimize_initial_public(agent, opponent, public_space)
        args_to_rem = Set.new
        old_set     = nil
        loop do
          public_space.arguments.each do |arg|
            args_to_rem << Predicate.new(:pub, arg)
            [agent, opponent].each do |ag|
              ag.rules.each do |rule|
                rule.alternatives.each do |alt|
                  alt.modifiers.select{|m| m.predicate.type == :pub}.each do |mod|
                    args_to_rem.delete(mod.predicate.unsided) if (mod.type == :rem) == public_space.initial_state[mod.predicate.argument1]
                  end
                end
              end
            end
          end
          break if args_to_rem.empty? || args_to_rem == old_set
          args_to_rem.each do |arg|
            public_space.arguments.delete(arg.argument1)
            [agent, opponent].each do |ag|
              act_to_rem = []
              ag.rules.each_with_index do |act, act_i|
                if (index = act.premises.lazy.map(&:unsided).find_index(arg))
                  if public_space.initial_state[arg.argument1] == act.premises[index].positive
                    act.premises.delete_at(index)
                  else
                    act_to_rem << act_i
                  end
                end
              end
              act_to_rem.reverse_each do |act_i|
                ag.rules.delete_at(act_i)
                ag.action_names.delete_at(act_i) if(ag.respond_to?(:action_names))
              end
              puts "Rules removed: #{act_to_rem.size}"
            end
          end
          old_set = Set.new(args_to_rem)
          args_to_rem.clear
        end
      end
    end

    private_class_method :optimize_args, :optimize_initial, :optimize_initial_agent
  end
end