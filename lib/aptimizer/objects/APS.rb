module Aptimizer
  class APS
    attr_reader :discount, :agent, :opponent, :public_space

    def initialize(discount, agent, opponent, public_space)
      @discount     = discount
      @agent        = agent
      @opponent     = opponent
      @public_space = public_space
    end

    def to_s
      %Q{
Agent internal arguments: #{agent.arguments}
Opponent internal arguments: #{opponent.arguments}
Attacks: #{public_space.attacks.join(", ")}
Agent goal: #{agent.goals.to_a.join(" &")}

Agent rules:\n#{agent.action_names.zip(agent.actions).map{|n,a| "#{n}: #{a}"}.join("\n")}

Opponent rules:\n#{(0...opponent.rules.size).zip(opponent.rules).map{|n,a| "r#{n}: #{a}"}.join("\n")}
      }
    end
  end
end