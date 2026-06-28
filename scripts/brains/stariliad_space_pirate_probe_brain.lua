require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/findflower"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/faceentity"

local BrainCommon = require("brains/braincommon")

local RUN_AWAY_DIST = 15
local STOP_RUN_AWAY_DIST = 30

local StarIliadSpacePirateProbeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function LightControlAction(inst)
    inst._light_enable:set(inst:IsTargetInRange())

    if inst._light_enable:value() then
        if inst.AnimState:IsCurrentAnimation("idle") then
            inst.AnimState:PlayAnimation("scan_loop", true)
        elseif inst.AnimState:IsCurrentAnimation("walk_pre")
            or inst.AnimState:IsCurrentAnimation("walk_loop")
            or inst.AnimState:IsCurrentAnimation("walk_pst") then
            inst.AnimState:PlayAnimation("scan_loop")
        end
    else

    end
end

local function GetFollowTarget(inst)
    local target = inst.components.entitytracker:GetEntity("target")
    if target and target:IsValid() then
        return target
    end
end

local function KeepFaceTarget(inst, target)
    return GetFollowTarget(inst) == target and inst:IsTargetInRange()
end

local function GetRunAwayTarget(inst)
    local player = FindClosestPlayerToInst(inst, PLAYER_CAMERA_SEE_DISTANCE)
    if player then
        return player
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local characters = TheSim:FindEntities(x, 0, z, PLAYER_CAMERA_SEE_DISTANCE, nil, { 'INLIMBO' },
        { "character", "largecreature" })
    return characters[1]
end


function StarIliadSpacePirateProbeBrain:OnStart()
    local root = PriorityNode(
        {
            -- FailIfSuccessDecorator(ActionNode(function() LightControlAction(self.inst) end)),

            WhileNode(
                function()
                    return GetFollowTarget(self.inst) ~= nil
                end,
                "FollowTarget",
                PriorityNode({
                    Follow(self.inst,
                        function() return GetFollowTarget(self.inst) end,
                        1,
                        TUNING.STARILIAD_SPACE_PIRATE_PROBE_SCAN_RANGE * 0.6,
                        TUNING.STARILIAD_SPACE_PIRATE_PROBE_SCAN_RANGE,
                        false
                    ),

                    FaceEntity(self.inst, GetFollowTarget, KeepFaceTarget),

                    -- StandStill(self.inst),
                }, 0.1)

            ),

            -- WhileNode(
            --     function()
            --         return GetFollowTarget(self.inst) == nil
            --     end, "RunAway",
            --     RunAway(self.inst, { getfn = GetRunAwayTarget }, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
            -- ),

            RunAway(self.inst, { getfn = GetRunAwayTarget }, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),

        }, 0.5)

    self.bt = BT(self.inst, root)
end

return StarIliadSpacePirateProbeBrain
