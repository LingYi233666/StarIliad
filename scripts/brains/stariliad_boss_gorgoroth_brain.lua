require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"

local BrainCommon = require "brains/braincommon"

local MAX_CHASE_DIST = 32
local MAX_CHASE_TIME = 20

local HOME_POS_DIST_FIX = 0.2

local StarIliadBossGorgorothBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.combat:HasTarget() then
        return
    end

    local home_pos = inst.components.knownlocations:GetLocation("home")
    return home_pos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home_pos, nil, HOME_POS_DIST_FIX)
        or nil
end

local function ShouldRoar(inst)
    return inst.components.combat:HasTarget()
        and inst.sg:HasStateTag("idle")
        and (inst.next_roar_time == nil or GetTime() >= inst.next_roar_time)
end

local function ShouldSpit(inst)
    return inst.components.combat:HasTarget()
        and inst.components.health:GetPercent() < 0.9
        and inst.sg:HasStateTag("idle")
        and (inst.last_spit_time == nil or GetTime() - inst.last_spit_time > 20)
    -- and (inst.last_spit_time == nil or GetTime() - inst.last_spit_time > 5)
end

local function ShouldHopStill(inst)
    return not inst.components.combat:HasTarget()
        and inst.sg:HasStateTag("idle")
        and inst:CheckHopCooldown(inst.hop_still_cd)
end

local function ShouldGoHome(inst)
    local home_pos = inst.components.knownlocations and inst.components.knownlocations:GetLocation("home")

    return home_pos and (home_pos - inst:GetPosition()):Length() > HOME_POS_DIST_FIX
end


------------------------------------------------------------------------------------------

function StarIliadBossGorgorothBrain:OnStart()
    local root =
        PriorityNode(
            {
                -- BrainCommon.PanicTrigger(self.inst),
                -- BrainCommon.ElectricFencePanicTrigger(self.inst),

                -- Roar is taunt
                WhileNode(function() return ShouldRoar(self.inst) end, "ShouldRoar",
                    ActionNode(function()
                        self.inst.next_roar_time = GetTime() + math.random(16, 20)
                        self.inst.sg:GoToState("roar")
                    end)),

                -- Spit some gelblob ?
                WhileNode(function() return ShouldSpit(self.inst) end, "ShouldSpit",
                    ActionNode(function()
                        self.inst.last_spit_time = GetTime()

                        local pos_queue = self.inst:GenerateSpitPos(math.random(3, 5))
                        if #pos_queue > 0 then
                            self.inst.sg:GoToState("spit", { pos_queue = pos_queue })
                        end
                    end)),

                -- WhileNode(function() return not ShouldRoar(self.inst) and not ShouldSpit(self.inst) end, "ChaseAndAttack",
                --     ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),

                -- Go back to spawn point
                WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
                    DoAction(self.inst, GoHomeAction, "Go Home", true)),

                -- Hop and stand still at spawn point
                WhileNode(function() return ShouldHopStill(self.inst) end, "ShouldHopStill",
                    ActionNode(function()
                        self.inst.hop_still_cd = math.random(8, 12)
                        self.inst.sg:GoToState("hop", { standstill = true })
                    end)),

                StandStill(self.inst),
            }, 1)



    self.bt = BT(self.inst, root)
end

return StarIliadBossGorgorothBrain
