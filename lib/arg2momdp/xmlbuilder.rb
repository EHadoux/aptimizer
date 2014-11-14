require "nokogiri"

module Arg2MOMDP
  module POMDPX
    class XMLBuilder
      attr_reader :version, :id, :pomdpx

      def initialize(version, id, pomdpx)
        @version = version
        @id = id
        @pomdpx = pomdpx
      end

      def buildPOMDPX
        Nokogiri::XML::Builder.new(:encoding => "ISO-8859-1") do |xml|
          xml.pomdpx(:version => @version, :id => @id, 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:noNamespaceSchemaLocation' => "pomdpx.xsd") {
            xml.Discount @pomdpx.discount
            xml.Variable {
              build_variables(xml)
            }
            xml.InitialBeliefState {
              build_initial_state(xml)
            }
          }
        end.to_xml
      end

      private

      def build_variables(xml)
        build_arguments(xml, @pomdpx.agent, "1", true)
        build_arguments(xml, @pomdpx.public_state, "p", true)
        build_attacks(xml)
        build_arguments(xml, @pomdpx.opponent, "2", false)
        build_flags(xml)
        build_actions(xml)
        xml.RewardVar(:vname => "reward")
      end

      def build_initial_state(xml)
        build_argument_initial_state(xml, @pomdpx.agent, "1")
        build_argument_initial_state(xml, @pomdpx.public_state, "p")
        build_attacks_initial_state(xml)
        build_opponent_argument_initial_state(xml)
        build_flags_initial_state(xml)
      end

      def build_arguments(xml, agent, suffix, observable)
        agent.arguments.each do |a|
          xml.StateVar(:vnamePrev => "#{a}#{suffix}", :vnameCurr => "n#{a}#{suffix}", :fullyObs => "#{observable}") {
            xml.NumValues 2
          }
        end
      end

      def build_attacks(xml)
        @pomdpx.public_state.attacks.each do |a|
          xml.StateVar(:vnamePrev => "#{a.argument1}_#{a.argument2}", :vnameCurr => "n#{a.argument1}_#{a.argument2}",
                       :fullyObs => "true") {
            xml.NumValues 2
          }
        end
      end

      def build_flags(xml)
        @pomdpx.opponent.flags.each do |f|
          xml.StateVar(:vnamePrev => f[0], :vnameCurr => "n#{f[0]}") {
            xml.ValueEnum f[1].times.map {|i| "alt#{i+1}"}.join(" ")
          }
        end
      end

      def build_actions(xml)
        xml.ActionVar(:vname => "action") {
          if @pomdpx.agent.action_names.empty?
            xml.NumValues @pomdpx.agent.actions.size
          else
            xml.ValueEnum @pomdpx.agent.action_names.join(" ")
          end
        }
      end

      def build_argument_initial_state(xml, agent, suffix)
        agent.arguments.each do |a|
          xml.CondProb {
            xml.Var "#{a}#{suffix}"
            xml.Parent "null"
            xml.Parameter(:type => "TBL") {
              xml.Entry {
                xml.Instance "#{agent.initial_state[a] ? "s1" : "s0"}"
                xml.ProbTable 1.0
              }
            }
          }
        end
      end

      def build_attacks_initial_state(xml)
        @pomdpx.public_state.attacks.each do |a|
          atk_str = "#{a.argument1}_#{a.argument2}"
          xml.CondProb {
            xml.Var "#{atk_str}"
            xml.Parent "null"
            xml.Parameter(:type => "TBL") {
              xml.Entry {
                xml.Instance "#{@pomdpx.public_state.initial_state[atk_str] ? "s1" : "s0"}"
                xml.ProbTable 1.0
              }
            }
          }
        end
      end

      def build_opponent_argument_initial_state(xml)
        @pomdpx.opponent.arguments.each do |a|
          xml.CondProb {
            xml.Var "#{a}2"
            xml.Parent "null"
            xml.Parameter(:type => "TBL") {
              xml.Entry {
                xml.Instance "-"
                xml.ProbTable "uniform"
              }
            }
          }
        end
      end

      def build_flags_initial_state(xml)
        @pomdpx.opponent.flags.each do |f|
          xml.CondProb {
            xml.Var f[0]
            xml.Parent "null"
            xml.Parameter(:type => "TBL") {
              xml.Entry {
                xml.Instance "-"
                xml.ProbTable @pomdpx.opponent.rules[f[0][1..-1].to_i-1].alternatives.map {|a| a.probability }.join(" ")
              }
            }
          }
        end
      end
    end
  end
end
