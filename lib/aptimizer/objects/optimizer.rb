module Aptimizer
  class Optimizer
    attr_reader :premises_hash, :modif_hash

    def initialize(aps)
      fill_usage_hashes(aps)
    end

    def fill_usage_hashes(aps)
      @premises_hash = Hash.new(nil)
      @modif_hash    = Hash.new(nil)
      @user_hash     = Hash.new(nil)

      filler = ->(pred, hash) do
        case pred.type
          when :pub  then str = pred.argument1
          when :priv then str = "#{pred.argument1}#{pred.owner}"
          when :atk  then str = "#{pred.argument1}_#{pred.argument2}"
          else raise Error
        end
        if hash[str].nil?
          hash[str] = (pred.positive ? :pos : :neg)
        else
          hash[str] = :both if hash[str] != (pred.positive ? :pos : :neg)
        end
      end

      (aps.agent.rules.product([:agent]) + aps.opponent.rules.product([:opponent])).each do |r, a|
        r.premises.each  {|p| filler.(p, @premises_hash)}
        r.modifiers.each do |m|
          filler.(m.predicate, @modif_hash)
          if m.predicate.type == :pub
            arg = m.predicate.argument1
            @user_hash[arg] = a     if @user_hash[arg].nil?
            @user_hash[arg] = :both if @user_hash[arg] == :agent && a == :opponent
          end
        end
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
            when :initial    then modified = remove_incompatible_initial(aps, verbose) || modified
          end
          prune_empty_rules(aps, verbose)
        end
      end while modified && cycle
      aps
    end

    private

    def prune_empty_rules(aps, verbose)
      if verbose
        puts "\n--> Pruning empty rules:"
      end

      prune = ->(set) do
        removed = Array.new
        set.rules.each_with_index do |rule, r_index|
          removed << [rule, r_index] if rule.alternatives.map(&:modifiers).all?(&:empty?)
        end
        set.rules -= removed.map(&:first)
        removed
      end

      agent_removed = prune.(aps.agent)
      unless agent_removed.empty?
        if verbose
          puts "Agent rules removed: #{agent_removed.map{|_,r| aps.agent.action_names[r]}}"
        end
        agent_removed.reverse_each {|r| aps.agent.action_names.delete_at(r[1]) }
      end
      opp_removed = prune.(aps.opponent)
      unless opp_removed.empty?
        if verbose
          puts "Opponent rules removed: #{opp_removed.map{|_,r| "r#{r}"}}"
        end
      end

      fill_usage_hashes(aps) unless agent_removed.empty? && opp_removed.empty?
    end

    # Removes arguments not involved in any premise or modifier
    #
    # @param aps [APS] The APS to optimize
    def remove_irrelevant_args(aps, verbose)
      if verbose
        puts "\n--> Applying irrelevant arguments optimization:"
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
Attacks removed: #{atk_removed.map{|atk| "e(#{atk.argument1},#{atk.argument2})"}}}
      end
      !agent_removed.empty? || !opp_removed.empty? || !public_removed.empty? || !atk_removed.empty?
    end

    # Removes attacks from the rules if they are implicitely accessible
    def remove_enthymemes(aps, verbose)
      if verbose
        puts "\n--> Applying enthymemes optimization:"
      end
      removed = []
      aps.public_space.attacks.each do |atk|
        skip = false
        next unless @premises_hash["#{atk.argument1}_#{atk.argument2}"].nil? # Too difficult if the attack is in premise
        atking = Predicate.new(:pub, atk.argument1)
        atked  = Predicate.new(:pub, atk.argument2)
        (aps.agent.rules + aps.opponent.rules).each do |rule|
          break if skip
          rule.alternatives.each do |alt|
            atk_mod = arg_mod = nil
            alt.modifiers.each do |m|
              atk_mod = m.type if m.predicate == atk
              arg_mod = m.type if m.predicate == atking
            end
            atk_but_no_arg     = (arg_mod.nil? && !atk_mod.nil?)
            atk_arg_sides_diff = (!arg_mod.nil? && !atk_mod.nil? && (atk_mod != arg_mod))
            atk_but_no_atked   = (atk_mod == :add && !rule.premises.include?(atked))
            if atk_but_no_arg || atk_arg_sides_diff || atk_but_no_atked
              skip = true
              break
            end
          end
        end
        removed << atk unless skip
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
    def remove_dominated(aps, verbose)
      if verbose
        puts "\n--> Applying dominated arguments optimization:"
      end
      graph = AtkGraph::Graph.new
      aps.public_space.backup_attacks.each do |atk| # Creates the graph
        arg1 = atk.argument1
        arg2 = atk.argument2
        next if @user_hash[arg1].nil? || @user_hash[arg2].nil?
        v1   = AtkGraph::Vertex.new(arg1)
        v2   = AtkGraph::Vertex.new(arg2)
        graph.add_atk(v1, v2)
      end

      modified = false
      loop do
        to_rem = graph.vertices.select {|v| v.dominated? && @user_hash[v.value] == :agent} # Gets all dominated arguments of agent 1
        break if to_rem.empty?
        modified = true
        to_rem.each do |vertex|
          aps.agent.arguments.delete(vertex.value)
          puts "Argument #{vertex.value} removed" if verbose
          aps.agent.actions.reverse.each do |act|
            act.alternatives[0].modifiers.delete_if {|m| m.predicate.argument1 == vertex.value} # Removes modifiers
            act.premises.delete_if {|p| p.argument1 == vertex.value}
          end
          graph.vertices.delete(vertex)
        end
      end
      modified
    end

    def remove_incompatible_initial(aps, verbose)
      if verbose
        puts "\n--> Applying incompatible initial arguments optimization:"
      end
      checker = ->(rules, type, suffix, initial) do
        mod = false
        rules.each do |r|
          r.premises.select{|p| p.type == type}.each do |p|
            if @modif_hash["#{p.argument1}#{suffix}"].nil?
              print "#{p.argument1}#{suffix} optimizes #{r}" if verbose
              if @premises_hash["#{p.argument1}#{suffix}"] != (initial[p.argument1] ? :pos : :neg)
                r.alternatives.each{|a| a.modifiers.clear}
              else
                r.premises.reject!{|prem| p == prem}
              end
              puts " to #{r}"
              mod = true
            else # !@modif_hash["#{p.argument1}1"].nil?
              if @modif_hash["#{p.argument1}#{suffix}"] == (initial[p.argument1] ? :pos : :neg)
                print "#{p.argument1}#{suffix} optimizes #{r}" if verbose
                r.alternatives.each{|a| a.modifiers.clear}
                puts " to #{r}"
                mod = true
              end
            end
          end
        end
        mod
      end
      modified = checker.(aps.agent.rules, :priv, 1, aps.agent.initial_state)
      modified = checker.(aps.agent.rules, :pub, "", aps.public_space.initial_state) || modified
      checker.(aps.opponent.rules, :pub, "", aps.public_space.initial_state) || modified
    end
  end
end
