require "behaviours/chaseandattack"
require "behaviours/wander"

local StariliadSampleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StariliadSampleBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(
                function()
                    return self.inst.components.combat.target ~= nil
                        and self.inst.components.combat:InCooldown()
                end,
                "AvoidTarget",
                RunAway(self.inst, {
                    getfn = function()
                        return self.inst.components.combat.target
                    end
                }, 5, 8)
            ),

            ChaseAndAttack(self.inst,
                20, -- max chase time
                50  -- max chase distance
            ),

            Wander(self.inst,
                nil, -- home location
                32   -- max wander distance
            ),
        }, .25)

    self.bt = BT(self.inst, root)
end

return StariliadSampleBrain
