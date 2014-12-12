require "nokogiri"

module Arg2MOMDP
  module POMDPX
    class XMLBuilder
      attr_reader :version, :id, :pomdp

      def initialize(version, id, pomdp)
        @version = version
        @id = id
        @pomdp = pomdp
      end

      def build_pomdpx(*parts)
        flags_list = [:var, :init, :transitions, :reward]
        f = (parts - flags_list) and (raise "Unknown flags :#{f}" unless f.empty?)
        parts = flags_list if parts.empty?
        Nokogiri::XML::Builder.new(:encoding => "ISO-8859-1") do |xml|
          xml.pomdpx(:version => @version, :id => @id, 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:noNamespaceSchemaLocation' => "pomdpx.xsd") {
            xml.Discount @pomdp.discount
            if parts.include?(:var)
              xml.Variable {
                VariableBuilder.build_variables(xml, pomdp)
              }
            end
            if parts.include?(:init)
              xml.InitialStateBelief {
                InitialStateBuilder.build_initial_state(xml, pomdp)
              }
            end
            if parts.include?(:transitions)
              xml.StateTransitionFunction {
                TransitionBuilder.build_transitions(xml, pomdp)
              }
            end
            if parts.include?(:reward)
              xml.RewardFunction {
                xml.Func {
                  xml.Var "reward"
                  RewardBuilder.build_reward(xml, pomdp.agent, pomdp.public_space)
                }
              }
            end
          }
        end.to_xml
      end
    end
  end
end
