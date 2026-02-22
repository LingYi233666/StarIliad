require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/minperiod"
local BrainCommon = require("brains/braincommon")

local StarIliadBossSpyderBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


local function CanCharge(inst)
    return inst.can_charge
        and inst:InChargeRadius()
        and not inst.components.health:IsDead()
        and not inst.sg:HasStateTag("busy")
end

local function DoCharge(inst)
    inst.can_charge = false
    inst.sg:GoToState("charge_pre")
end

function StarIliadBossSpyderBrain:OnStart()
    local root = PriorityNode(
        {

            IfNode(function() return CanCharge(self.inst) end, "CanCharge",
                ActionNode(function() DoCharge(self.inst) end)),

            -- IfNode(function() return self:CanSpawnChild() end, "needs follower",
            --     ActionNode(function()
            --         self.inst.sg:GoToState("poop_pre")
            --         return SUCCESS
            --     end, "make child")),

            --SPIDERQUEEN_MINDENSPACING

            ChaseAndAttack(self.inst, 60, 60, nil, nil, true),
            Wander(self.inst),
        }, 0.5)

    self.bt = BT(self.inst, root)
end

return StarIliadBossSpyderBrain
