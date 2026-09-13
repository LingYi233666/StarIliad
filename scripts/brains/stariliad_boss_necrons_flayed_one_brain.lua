require "behaviours/chaseandattack"
require "behaviours/wander"

local StariliadBossNecronsFlayedOneBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StariliadBossNecronsFlayedOneBrain:OnStart()
    local root = PriorityNode(
        {
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

return StariliadBossNecronsFlayedOneBrain
