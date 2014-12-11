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

      def build_pomdpx(*parts)
        parts = [:var, :init, :transitions, :reward] if parts.empty?
        Nokogiri::XML::Builder.new(:encoding => "ISO-8859-1") do |xml|
          xml.pomdpx(:version => @version, :id => @id, 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:noNamespaceSchemaLocation' => "pomdpx.xsd") {
            xml.Discount @pomdpx.discount
            if parts.include?(:var)
              xml.Variable {
                VariableBuilder.build_variables(xml, pomdpx)
              }
            end
            if parts.include?(:init)
              xml.InitialStateBelief {
                InitialStateBuilder.build_initial_state(xml, pomdpx)
              }
            end
            if parts.include?(:transitions)
              xml.StateTransitionFunction {
                TransitionBuilder.build_transitions(xml, pomdpx)
              }
            end
            if parts.include?(:reward)
              xml.RewardFunction {
                xml.Func {
                  xml.Var "reward"
                  RewardBuilder.build_reward(xml, pomdpx.agent, pomdpx.public_space)
                }
              }
            end
          }
        end.to_xml
      end
    end
  end
end
