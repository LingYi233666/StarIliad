require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"

local BrainCommon = require "brains/braincommon"

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 32

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local AVOID_TARGET_DIST = 5
local STOP_AVOID_TARGET_DIST = 8

local HIGH_SPEED_CHASE_CD = 12
local HIGH_SPEED_CHASE_DIST = 8

local StarIliadSpacePirateBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetTraderFn(inst)
    if inst.components.trader ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = FindPlayersInRangeSq(x, y, z, TRADE_DIST_SQ, true)
        for _, player in ipairs(players) do
            if inst.components.trader:IsTryingToTradeWithMe(player) then
                return player
            end
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader ~= nil
        and inst.components.trader:IsTryingToTradeWithMe(target)
end

local EATFOOD_CANT_TAGS = { "INLIMBO", "outofreach" }
local function IsFoodValid(item, inst)
    return inst.components.eater:CanEat(item)
        and item:IsOnValidGround()
        and item:GetTimeAlive() > TUNING.SPIDER_EAT_DELAY
end

local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, IsFoodValid, nil, EATFOOD_CANT_TAGS,
        inst.components.eater:GetEdibleTags())
    return target ~= nil and BufferedAction(inst, target, ACTIONS.EAT) or nil
end

local function GoHomeAction(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil

    if home ~= nil and ((home.components.burnable ~= nil and home.components.burnable:IsBurning()) or
            (home.components.freezable ~= nil and home.components.freezable:IsFrozen()) or
            (home.components.health ~= nil and home.components.health:IsDead())) then
        home = nil
    end

    return home ~= nil
        and home:IsValid()
        and home.components.childspawner ~= nil
        and (home.components.health == nil or not home.components.health:IsDead())
        and BufferedAction(inst, home, ACTIONS.GOHOME)
        or nil
end

local function InvestigateAction(inst)
    local investigatePos = inst.components.knownlocations ~= nil and
        inst.components.knownlocations:GetLocation("investigate") or nil
    return investigatePos ~= nil and BufferedAction(inst, nil, ACTIONS.INVESTIGATE, nil, investigatePos, nil, 1) or nil
end

local function GetCombatTargetFn(inst)
    return inst.components.combat.target
end

local function CanCastHighSpeedChase(inst)
    if inst.last_cast_high_speed_chase_time ~= nil
        and GetTime() - inst.last_cast_high_speed_chase_time < HIGH_SPEED_CHASE_CD then
        return false
    end

    local target = inst.components.combat.target
    if not (target and target:IsValid()) then
        return false
    end

    return StarIliadBasic.GetFaceAngle(inst, target) < 60
        and not inst.components.health:IsDead()
        and not inst.components.combat:InCooldown()
        and not inst.sg:HasStateTag("busy")
        and inst.sg:HasStateTag("running")
        and inst:IsNear(target, HIGH_SPEED_CHASE_DIST)
end

local function CastHighSpeedChase(inst)
    inst:AddDebuff("stariliad_debuff_pirate_high_speed", "stariliad_debuff_pirate_high_speed")
    inst.last_cast_high_speed_chase_time = GetTime()
end

------------------------------------------------------------------------------------------

function StarIliadSpacePirateBrain:OnStart()
    -- local SPITTER_SEE_DIST  = TUNING.SPIDER_SPITTER_ATTACK_RANGE - .5
    -- local SPITTER_SAFE_DIST = TUNING.SPIDER_SPITTER_ATTACK_RANGE

    -- local pre_nodes         = PriorityNode({
    --     BrainCommon.PanicWhenScared(self.inst, .3),
    --     BrainCommon.PanicTrigger(self.inst),
    --     BrainCommon.ElectricFencePanicTrigger(self.inst),
    -- })

    -- local post_nodes        = PriorityNode({
    --     DoAction(self.inst, function() return InvestigateAction(self.inst) end),

    --     WhileNode(function() return (TheWorld.state.iscaveday or self.inst._quaking) and not self.inst.summoned end,
    --         "IsDay",
    --         DoAction(self.inst, function() return GoHomeAction(self.inst) end)),

    --     FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
    --     Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    -- })

    -- local hider_nodes       = PriorityNode({
    --     IfNode(function() return self.inst:HasTag("spider_hider") end, "IsHider",
    --         UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS, HIDE_WHEN_SCARED)),
    -- })

    -- local attack_nodes      = PriorityNode({
    --     IfNode(function() return not self.inst.bedazzled and GetLeader(self.inst) == nil end, "AttackWall",
    --         AttackWall(self.inst)
    --     ),

    --     RunAway(self.inst, AcidInfusedSpitter_ShouldRunAway, SPITTER_SEE_DIST, SPITTER_SAFE_DIST),
    --     FaceEntity(self.inst, AcidInfusedSpitter_GetFaceTargetFn, AcidInfusedSpitter_KeepFaceTargetFn),

    --     ChaseAndAttack(self.inst, SpringCombatMod(TUNING.SPIDER_AGGRESSIVE_MAX_CHASE_TIME)),
    -- })

    -- local aggressive_follow = PriorityNode({
    --     DoAction(self.inst, function() return EatFoodAction(self.inst) end),
    --     Follow(self.inst, function() return GetLeader(self.inst) end,
    --         TUNING.SPIDER_AGGRESSIVE_MIN_FOLLOW, TUNING.SPIDER_AGGRESSIVE_MED_FOLLOW, TUNING
    --         .SPIDER_AGGRESSIVE_MAX_FOLLOW),
    -- })

    -- local defensive_follow  = PriorityNode({
    --     Follow(self.inst, function() return GetLeader(self.inst) end,
    --         TUNING.SPIDER_DEFENSIVE_MIN_FOLLOW, TUNING.SPIDER_DEFENSIVE_MED_FOLLOW, TUNING.SPIDER_DEFENSIVE_MAX_FOLLOW),
    -- })

    -- local follow_nodes      = PriorityNode({
    --     IfNode(function() return self.inst.defensive end, "DefensiveFollow",
    --         defensive_follow),

    --     IfNode(function() return not self.inst.defensive end, "AggressiveFollow",
    --         aggressive_follow),

    --     IfNode(function() return GetLeader(self.inst) ~= nil end, "HasLeader",
    --         FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
    -- })

    self.chase_and_attack_node = ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)

    local combat_node =
        PriorityNode(
            {
                WhileNode(
                    function()
                        return self.inst.components.combat:InCooldown()
                    end,
                    "AvoidTarget",
                    RunAway(self.inst, { getfn = GetCombatTargetFn }, AVOID_TARGET_DIST, STOP_AVOID_TARGET_DIST)
                ),

                IfNode(
                    function()
                        return self.chase_and_attack_node.state == RUNNING and CanCastHighSpeedChase(self.inst)
                    end,
                    "CanCastHighSpeedChase",
                    ActionNode(function() CastHighSpeedChase(self.inst) end)
                ),

                self.chase_and_attack_node,
            },
            0.5
        )


    local peace_node = PriorityNode(
        {
            Wander(self.inst, nil, MAX_WANDER_DIST),
        },
        1.0
    )


    local root =
        PriorityNode(
            {
                WhileNode(
                    function()
                        return self.inst.components.combat:HasTarget()
                    end,
                    "Combat",
                    combat_node
                ),


                peace_node,
            },
            1
        )

    self.bt    = BT(self.inst, root)
end

return StarIliadSpacePirateBrain
