module Arg2MOMDP
  module POMDPX
    class InitialStateBuilder
      extend Helpers
      class << self
        def build_initial_state(xml, pomdpx)
          build_argument_initial_state(xml, pomdpx.agent, "1")
          build_argument_initial_state(xml, pomdpx.public_state, "p")
          build_attacks_initial_state(xml, pomdpx.public_state)
          build_opponent_argument_initial_state(xml, pomdpx.opponent)
          build_flags_initial_state(xml, pomdpx.opponent)
        end

        def build_argument_initial_state(xml, agent, suffix)
          agent.arguments.each do |a|
            build_cond_prob(xml, "#{a}#{suffix}", "null", "#{agent.initial_state[a] ? "s1" : "s0"}", 1.0)
          end
        end

        def build_attacks_initial_state(xml, public_state)
          public_state.attacks.each do |a|
            atk_str = convert_string(a)
            build_cond_prob(xml, atk_str, "null", "#{public_state.initial_state[atk_str] ? "s1" : "s0"}", 1.0)
          end
        end

        def build_opponent_argument_initial_state(xml, opponent)
          opponent.arguments.each do |a|
            build_cond_prob(xml, "#{a}2", "null", "-", "uniform")
          end
        end

        def build_flags_initial_state(xml, opponent)
          opponent.flags.each do |f|
            build_cond_prob(xml, f[0], "null", "-", opponent.rules[f[0][1..-1].to_i-1].alternatives.map {|a| a.probability}.join(" "))
          end
        end
      end
    end
  end
end