module Arg2MOMDP
  module POMDPX
    class VariableBuilder
      class << self
        def build_variables(xml, pomdpx)
          build_arguments(xml, pomdpx.agent, "1", true)
          build_arguments(xml, pomdpx.public_space, "p", true)
          build_attacks(xml, pomdpx.public_space)
          build_arguments(xml, pomdpx.opponent, "2", false)
          build_flags(xml, pomdpx.opponent)
          build_actions(xml, pomdpx.agent)
          xml.RewardVar(:vname => "reward")
        end

        def build_arguments(xml, agent, suffix, observable)
          agent.arguments.each do |a|
            xml.StateVar(:vnamePrev => "#{a}#{suffix}", :vnameCurr => "n#{a}#{suffix}", :fullyObs => "#{observable}") {
              xml.NumValues 2
            }
          end
        end

        def build_attacks(xml, public_state)
          public_state.attacks.each do |a|
            xml.StateVar(:vnamePrev => "#{a.argument1}_#{a.argument2}", :vnameCurr => "n#{a.argument1}_#{a.argument2}",
                         :fullyObs => "true") {
              xml.NumValues 2
            }
          end
        end

        def build_flags(xml, opponent)
          opponent.flags.each do |f|
            xml.StateVar(:vnamePrev => "_r#{f+1}", :vnameCurr => "_nr#{f+1}") {
              xml.ValueEnum opponent.rules[f].alternatives.size.times.map {|i| "alt#{i+1}"}.join(" ")
            }
          end
        end

        def build_actions(xml, agent)
          xml.ActionVar(:vname => "action") {
            if agent.action_names.empty?
              xml.NumValues agent.actions.size
            else
              xml.ValueEnum agent.action_names.join(" ")
            end
          }
        end
      end
      private_class_method :build_arguments, :build_attacks, :build_flags, :build_actions
    end
  end
end