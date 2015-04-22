module Aptimizer
  module POMDPX
    class RewardBuilder
      extend Helpers
      class << self
        def build_reward(xml, agent, public_space)
          goal_full_set_arr = get_goal_full_set(agent, public_space)
          xml.Parent goal_full_set_arr.map{|p| "n" + convert_string(p)}.join(" ")
          xml.Parameter(:type => "TBL") {
            build_entry(xml, "* " * goal_full_set_arr.size, -1)
            [false, true].repeated_permutation(goal_full_set_arr.size).sort_by{|p| p.count(true)}.each do |perm|
              if public_space.enthymeme
                next unless evaluate_goal_compliance_dr(goal_full_set_arr.zip(perm).to_h, agent, public_space)
              else
                next unless evaluate_goal_compliance(goal_full_set_arr.zip(perm).to_h)
              end
              build_entry(xml, perm.map{|val| "s#{val ? "1" : "0"} "}.join(""), 10)
            end
          }
        end

        def build_entry(xml, instance, value)
          xml.Entry {
            xml.Instance instance
            xml.ValueTable value
          }
        end
      end
      private_class_method :build_entry
    end
  end
end
