module Aptimizer
  module POMDPX
    class InitialStateBuilder
      extend Helpers
      class << self
        def build_initial_state(xml, pomdp)
          build_argument_initial_state(xml, pomdp.agent, "1")
          build_argument_initial_state(xml, pomdp.public_space, "p")
          build_attacks_initial_state(xml, pomdp.public_space)
          build_opponent_argument_initial_state(xml, pomdp.opponent)
          build_flags_initial_state(xml, pomdp.opponent)
        end

        def build_argument_initial_state(xml, agent, suffix)
          agent.arguments.each do |a|
            name    = "#{a}#{suffix}"
            parents = "null"
            state   = (agent.initial_state[a] ? "s1" : "s0")
            prob    = 1.0
            build_cond_prob(xml, name, parents, state, prob)
          end
        end

        def build_attacks_initial_state(xml, public_state)
          public_state.attacks.each do |a|
            atk_str = convert_string(a)
            parents = "null"
            state   = (public_state.initial_state[atk_str] ? "s1" : "s0")
            prob    = 1.0
            build_cond_prob(xml, atk_str, parents, state, prob)
          end
        end

        def build_opponent_argument_initial_state(xml, opponent)
          opponent.arguments.each do |a|
            name    = "#{a}2"
            parents = "null"
            state   = "-"
            prob    = "uniform"
            build_cond_prob(xml, name, parents, state, prob)
          end
        end

        def build_flags_initial_state(xml, opponent)
          opponent.flags.each do |f|
            name    = "_r#{f+1}"
            parents = "null"
            state   = "-"
            prob    = opponent.rules[f].alternatives.map(&:probability).join(" ")
            build_cond_prob(xml, name, parents, state, prob)
          end
        end
      end
      private_class_method :build_argument_initial_state, :build_attacks_initial_state,
                           :build_opponent_argument_initial_state, :build_flags_initial_state
    end
  end
end