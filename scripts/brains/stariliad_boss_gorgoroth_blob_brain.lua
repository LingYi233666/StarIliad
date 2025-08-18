require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"

local BrainCommon = require "brains/braincommon"

local StarIliadBossGorgorothBlobBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ReturnAction(inst)
    local mainblob = inst.components.entitytracker:GetEntity("mainblob")
    if mainblob and mainblob:IsValid() and not inst.sg:HasStateTag("busy") then
        --  doer, target, action, invobject, pos, recipe, distance, forced, rotation, arrivedist
        return BufferedAction(inst, mainblob, ACTIONS.STARILIAD_BLOB_RETURN, nil, nil, nil, nil, nil, nil, 0.1)
    end
end

local function ShouldReturn(inst)
    local mainblob = inst.components.entitytracker:GetEntity("mainblob")

    return mainblob
        and mainblob:IsValid()
        and not mainblob.components.health:IsDead()
        and inst:IsNear(mainblob, 40)
        and not inst.sg:HasStateTag("busy")
end

local function GetMainPos(inst)
    local mainblob = inst.components.entitytracker:GetEntity("mainblob")
    if mainblob and mainblob:IsValid() then
        return mainblob:GetPosition()
    end
end

------------------------------------------------------------------------------------------

function StarIliadBossGorgorothBlobBrain:OnStart()
    local root =
        PriorityNode(
            {
                -- WhileNode(function() return ShouldReturn(self.inst) end, "ShouldReturn",
                --     DoAction(self.inst, ReturnAction, "Return", true)),

                WhileNode(function() return ShouldReturn(self.inst) end, "ShouldReturn",
                    Leash(self.inst, GetMainPos, 1, 2)),

                StandStill(self.inst),
            }, 0.25)



    self.bt = BT(self.inst, root)
end

return StarIliadBossGorgorothBlobBrain
