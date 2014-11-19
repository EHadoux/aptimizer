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

      def build_pomdpx
        Nokogiri::XML::Builder.new(:encoding => "ISO-8859-1") do |xml|
          xml.pomdpx(:version => @version, :id => @id, 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:noNamespaceSchemaLocation' => "pomdpx.xsd") {
            xml.Discount @pomdpx.discount
            xml.Variable {
              VariableBuilder.build_variables(xml, pomdpx)
            }
            xml.InitialBeliefState {
              InitialStateBuilder.build_initial_state(xml, pomdpx)
            }
          }
        end.to_xml
      end

      private
      
    end
  end
end
