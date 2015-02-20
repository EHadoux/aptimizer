module Aptimizer
  class Optimizer
    attr_reader :premises_hash, :modif_hash

    def initialize(aps)
      @premises_hash = Hash.new(nil)
      @modif_hash    = Hash.new(nil)

      filler = ->(pred, hash) do
        case pred.type
          when :pub  then hash[pred.argument1]                        = true
          when :priv then hash["#{pred.argument1}#{pred.owner}"]      = true
          when :atk  then hash["#{pred.argument1}_#{pred.argument2}"] = true
        end
      end

      (aps.agent.rules + aps.opponent.rules).each do |r|
        r.premises.each  {|p| filler.(p, @premises_hash)}
        r.modifiers.each {|m| filler.(m.predicate, @modif_hash)}
      end
    end

    def optimize(aps, verbose=true, cycle=true, optimizations=[])
      aps if optimizations.include?(:none)
      flags_list = [:irrelevant, :initial, :enthymeme, :dominated]
      (f = (optimizations - flags_list)) and (raise "Unknown flags :#{f} Known flags are #{flags_list}" unless f.empty?)
      optimizations = flags_list if optimizations.empty?
      begin
        modified = false
        optimizations.each do |opt|
          case opt
            when :irrelevant then modified = remove_irrelevant_args(aps, verbose) || modified
            when :enthymeme  then modified = remove_enthymemes(aps, verbose) || modified
            when :dominated  then modified = remove_dominated(aps, verbose) || modified
            when :initial    then modified = optimize_initial(aps, verbose) || modified
          end
        end
      end while modified && cycle
      aps
    end

    private

    # Removes arguments not involved in any premise or modifier
    #
    # @param aps [APS] The APS to optimize
    def remove_irrelevant_args(aps, verbose)
      if verbose
        puts "--> Applying irrelevant arguments optimization:"
      end
      remove = ->(set, num="") do
        args = Array.new(set.arguments)
        set.arguments.each do |arg|
          if @premises_hash["#{arg}#{num}"].nil? and @modif_hash["#{arg}#{num}"].nil?
            args.delete(arg)
          end
        end
        removed       = set.arguments - args
        set.arguments = Array.new(args)
        removed
      end

      agent_removed  = remove.(aps.agent, "1")
      opp_removed    = remove.(aps.opponent, "2")
      public_removed = remove.(aps.public_space)
      atk_removed    = Array.new
      aps.public_space.attacks.each do |atk|
        str = "#{atk.argument1}_#{atk.argument2}"
        if @premises_hash[str].nil? and @modif_hash[str].nil?
          atk_removed << atk
          public_space.attacks.delete(atk)
          public_space.backup_attacks.delete(atk)
        end
      end

      if verbose
        puts %Q{Private arguments removed for agent 1: #{agent_removed.map{|a| "h(#{a})"}}
Private arguments removed for agent 2: #{opp_removed.map{|a| "h(#{a})"}}
Public arguments removed: #{public_removed.map{|a| "a(#{a})"}}
Attacks removed: #{atk_removed.map{|atk| "e(#{atk.argument1},#{atk.argument2})"}}
        }
      end
      !agent_removed.empty? || !opp_removed.empty? || !public_removed.empty? || !atk_removed.empty?
    end

    # Removes attacks from the rules if they are implicitely accessible
    def remove_enthymemes(aps, verbose)
      if verbose
        puts "--> Applying enthymemes optimization:"
      end
      removed = []
      aps.public_space.attacks.each do |atk|
        skip = false
        next if @premises_hash["#{atk.argument1}_#{atk.argument2}"] # Too difficult if the attack is in premise
        atking = Predicate.new(:pub, atk.argument1)
        atked  = Predicate.new(:pub, atk.argument2)
        (aps.agent.rules + aps.opponent.rules).each do |rule|
          break if skip
          rule.alternatives.each do |alt|
            atk_mod = nil
            arg_mod = nil
            alt.modifiers.each do |m|
              if m.predicate == atk
                atk_mod = m.type
              end
              if m.predicate == atking
                arg_mod = m.type
              end
            end
            if (arg_mod.nil? && !atk_mod.nil?) || (!arg_mod.nil? && !atk_mod.nil? && (atk_mod != arg_mod)) || (atk_mod == :add && !rule.premises.include?(atked))
              skip = true
              break
            end
          end
        end
        unless skip
          removed << atk
        end
      end

      removed.each do |atk|
        [aps.agent, aps.opponent].each do |ag|
          ag.rules.each do |rule|
            rule.alternatives.each do |alt|
              alt.modifiers.delete_if {|m| m.predicate == atk}
            end
          end
        end
        @modif_hash.delete("#{atk.argument1}_#{atk.argument2}")
        aps.public_space.attacks.delete atk
      end

      unless removed.empty?
        puts "Attacks removed: #{removed.map(&:to_s)}" if verbose
        aps.public_space.enthymeme = true
      end
      !removed.empty?
    end

    # Removes arguments of agent 1 that can never be defended
    def remove_dominated(pomdp, verbose)
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
          puts "Argument #{vertex.value} removed" if verbose
          pomdp.agent.actions.reverse.each_with_index do |act, act_i|
            act.alternatives[0].modifiers.delete_if {|m| m.predicate.argument1 == vertex.value} # Removes modifiers
            if act.alternatives[0].modifiers.empty? # If no more, removes the rule, otherwise, removes premises
              pomdp.agent.actions.delete_at(-(act_i+1))
              name = pomdp.agent.action_names.delete_at(-(act_i+1))
              puts "Action #{name} removed" if verbose
            else
              act.premises.delete_if {|p| p.argument1 == vertex.value}
            end
          end
          graph.vertices.delete(vertex)
        end
      end
    end

    def optimize_initial(aps, verbose)
      optimize_initial_agent(aps.agent, verbose)
      optimize_initial_public(aps.agent, aps.opponent, aps.public_space, verbose)
    end

    def optimize_initial_agent(agent, verbose)
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
          puts "Rule(s) removed: #{act_to_rem.size}" unless act_to_rem.size == 0 || !verbose
        end
        old_set = Set.new(args_to_rem)
        args_to_rem.clear
      end
    end

    def optimize_initial_public(agent, opponent, public_space, verbose)
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
        puts "Rule(s) removed: #{act_to_rem.size}" unless act_to_rem.size == 0 || !verbose
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
end
