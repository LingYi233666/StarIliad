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

local StarIliadBossGuardianBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldGoHome(inst)
    local home_pos = inst.components.knownlocations and inst.components.knownlocations:GetLocation("home")

    return home_pos and (home_pos - inst:GetPosition()):Length() > HOME_POS_DIST_FIX
end

local function GoHomeAction(inst)
    if inst.components.combat:HasTarget() then
        return
    end

    local home_pos = inst.components.knownlocations:GetLocation("home")
    return home_pos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home_pos, nil, HOME_POS_DIST_FIX)
        or nil
end

local function ShouldUseAbilityBase(inst)
    return inst.can_use_ability_time ~= nil
        and GetTime() >= inst.can_use_ability_time
        and not inst.components.health:IsDead()
        and not inst.sg:HasStateTag("busy")
end

local function ShouldDestroy3(inst)
    return inst.ability_name == "destroy3" and ShouldUseAbilityBase(inst)
end

local function UseDestroy3(inst)
    -- inst.components.talker:Say(STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_BOSS_GUARDIAN.DESTROY3)
    -- inst:SetEyeFlame(2)

    for _, v in pairs(AllPlayers) do
        if v:IsNear(inst, 50) then
            SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["show_destroy3_text"], v.userid, inst)
        end
    end

    inst:SetEyeFlame(1)


    inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/destroy3")

    inst.ability_name = "leap_attack"
    inst.can_use_ability_time = GetTime() + 6
end

local function ShouldLeapAttack(inst)
    local target = inst.components.combat.target
    return inst.ability_name == "leap_attack"
        and ShouldUseAbilityBase(inst)
        and target
        and inst:IsNear(target, 12)
end

local function UseLeapAttack(inst)
    local target = inst.components.combat.target
    inst.sg:GoToState("attack_leap", { pos = target:GetPosition() })

    inst.ability_name = "roar"
    inst.can_use_ability_time = GetTime() + 6
end

local function ShouldRoar(inst)
    return inst.ability_name == "roar" and ShouldUseAbilityBase(inst)
end

local function UseRoar(inst)
    inst.sg:GoToState("taunt1")

    inst.ability_name = "combo_punch"
    inst.can_use_ability_time = GetTime() + 6
end

------------------------------------------------------------------------------------------

function StarIliadBossGuardianBrain:OnStart()
    local aggressive_node = PriorityNode({
        WhileNode(function() return ShouldDestroy3(self.inst) end, "Destroy3",
            ActionNode(function()
                UseDestroy3(self.inst)
            end)),

        WhileNode(function() return ShouldLeapAttack(self.inst) end, "LeapAttack",
            ActionNode(function()
                UseLeapAttack(self.inst)
            end)),

        WhileNode(function() return ShouldRoar(self.inst) end, "Roar",
            ActionNode(function()
                UseRoar(self.inst)
            end)),

        -- Combo punch is written in doattack event
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST, nil, nil, true),

    }, 1)

    local defensive_node = PriorityNode({
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
    }, 1)

    local peace_node = PriorityNode({
        -- Go back to spawn point
        -- WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
        --     DoAction(self.inst, GoHomeAction, "Go Home", true)),

        StandStill(self.inst),
    }, 1)

    local root =
        PriorityNode(
            {
                -- BrainCommon.PanicTrigger(self.inst),
                -- BrainCommon.ElectricFencePanicTrigger(self.inst),

                WhileNode(
                    function()
                        return self.inst.defensive_mode == false and self.inst.components.combat:HasTarget()
                    end,
                    "Aggressive",
                    aggressive_node),

                WhileNode(
                    function()
                        return self.inst.defensive_mode == true and self.inst.components.combat:HasTarget()
                    end,
                    "Defensive",
                    defensive_node),

                peace_node

            }, 1)



    self.bt = BT(self.inst, root)
end

return StarIliadBossGuardianBrain
