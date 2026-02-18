require("stategraphs/commonstates")

local function hit_recovery_skip_cooldown_fn(inst, last_t, delay)
    return inst.components.combat:InCooldown() and inst.sg:HasStateTag("idle")
end

local events =
{
    CommonHandlers.OnAttacked(nil, 1, hit_recovery_skip_cooldown_fn),
    CommonHandlers.OnLocomote(true, true),

    EventHandler("death", function(inst, data)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death_pre", data)
        end
    end),


    EventHandler("doattack", function(inst, data)
        if inst.components.health and not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or
                (inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute"))
            )
        then
            local target = data and data.target or inst.components.combat.target
            if not (target and target:IsValid()) then
                return
            end

            if inst.defensive_mode then
                inst.sg:GoToState("attack_counter", { target = target })
            elseif inst.ability_name == "combo_punch" then
                print("Use combo_punch !")
                inst.sg:GoToState("attack1", {
                    target = target,
                    count = 5,
                    uppercut = true,
                })
                inst.ability_name = "destroy3"
                inst.can_use_ability_time = GetTime() + 6
            else
                -- inst.sg:GoToState("attack1", { target = target, count = 1, uppercut = false, })
                inst.sg:GoToState("attack1", { target = target })
            end
        end
    end),


    EventHandler("defensive_mode_change", function(inst, data)
        if inst.components.health:IsDead() then
            return
        end

        if inst.defensive_mode then
            -- inst:SetEyeFlame(1)
            inst:SetEyeFlame(0)


            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("enter_defensive_mode")
            else
                inst.sg.mem.enter_defensive_mode = true
            end
        else
            SpawnAt("stariliad_boss_guardian_break_fx", inst)
            if inst.components.combat:HasTarget() then
                inst.sg:GoToState("taunt2")
            elseif not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("leave_defensive_mode")
            end
        end
    end),
}

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .015, .25, inst, 10)
end

local function ShakePound(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 0.5, .03, .5, inst, 30)
end

local function ShakeRoar(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 0.8, .03, .5, inst, 30)
end

local function PlayPoundSounds(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")
    -- inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/bodyfall")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
    inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/chain_hit")
end

local function PlayChestPoundSounds(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")
    inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/chain_hit")
end

local function DoAreaAttack(inst, range, facing_angle, work_damage)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range + 4, nil, { "INLIMBO", "FX" })

    local victims = {}
    for _, v in pairs(ents) do
        if v:IsValid() and (facing_angle == nil or StarIliadBasic.GetFaceAngle(inst, v) <= facing_angle * 0.5) and inst:IsNear(v, range + v:GetPhysicsRadius(0)) then
            if inst.components.combat:CanTarget(v) and not inst.components.combat:IsAlly(v) then
                inst.components.combat:DoAttack(v)
                table.insert(victims, v)
            elseif v.components.workable and v.components.workable:CanBeWorked() and v.components.workable.action ~= ACTIONS.NET then
                v.components.workable:WorkedBy(inst, work_damage or 5)
                table.insert(victims, v)
            end
        end
    end

    return victims
end

local function DoPunchAttack(inst)
    DoAreaAttack(inst, inst.components.combat:GetHitRange(), 120)
end

local function DoCounterAttack(inst)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_COUNTER_DAMAGE)

    DoAreaAttack(inst, inst.components.combat:GetHitRange(), 120)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
end


local function DoUppercutAttack(inst)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_UPPERCUT_DAMAGE)

    local victims = DoAreaAttack(inst, inst.components.combat:GetHitRange(), 100)
    for _, v in pairs(victims) do
        if v:IsValid() then
            v:PushEvent("knockback", { knocker = inst, radius = 5 })
            --  { knocker = inst, radius = 5, strengthmult = strengthmult, forcelanded = forcelanded })
        end
    end

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
end

local function DoLeapPound(inst)
    ShakePound(inst)
    PlayPoundSounds(inst)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_LEAP_DAMAGE)

    local victims = DoAreaAttack(inst, 6, nil, 20)
    for _, v in pairs(victims) do
        if v:IsValid() then
            -- v:PushEvent("knockback", { knocker = inst, radius = 8, strengthmult = 2 })
            v:PushEvent("knockback", { knocker = inst, radius = 5 })
        end
    end

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
end

local function DoTauntPound1(inst)
    ShakePound(inst)
    PlayPoundSounds(inst)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_TAUNT_POUND_DAMAGE)
    DoAreaAttack(inst, 6, nil, 2)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
end

local function DoTauntPound2(inst)
    ShakePound(inst)
    PlayPoundSounds(inst)

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_TAUNT_POUND_DAMAGE)

    local victims = DoAreaAttack(inst, 6, nil, 2)
    for _, v in pairs(victims) do
        if v:IsValid() then
            v:PushEvent("knockback", { knocker = inst, radius = 4 })
        end
    end

    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
end

-- local function MakePowerOnOffLines(start_t, dt, counts)
--     local timeline = {}

--     for i = 1, counts do
--         table.insert(timeline,
--             TimeEvent(start_t + dt * (i * 2 - 2), function(inst)
--                 inst:SetBluePower(true)
--             end)
--         )
--         table.insert(timeline,
--             TimeEvent(start_t + dt * (i * 2 - 1), function(inst)
--                 inst:SetBluePower(false)
--             end)
--         )
--     end

--     return unpack(timeline)
-- end

local states =
{
    State {
        name = "attack3", --uppercut
        tags = { "attack", "busy" },

        onenter = function(inst, data)
            data = data or {}

            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()

            inst.AnimState:PlayAnimation("attack3")

            if data.target and data.target:IsValid() then
                inst.sg.statemem.target = data.target
                inst:ForceFacePoint(data.target:GetPosition())
            end

            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/swipe")
        end,

        timeline = {
            TimeEvent(3 * FRAMES, DoUppercutAttack),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "attack_counter",
        tags = { "attack", "busy" },

        onenter = function(inst, data)
            data = data or {}

            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()

            inst.AnimState:PlayAnimation("block_counter")

            if data.target and data.target:IsValid() then
                inst.sg.statemem.target = data.target
                inst:ForceFacePoint(data.target:GetPosition())
            end

            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/swipe")
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                DoCounterAttack(inst)
                inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/attack")
            end),
        },

        events =
        {
            -- EventHandler("onhitother", function(inst)
            --     inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/attack")
            -- end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "attack_leap",
        tags = { "attack", "busy" },

        onenter = function(inst, data)
            data = data or {}

            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()
            inst:StopBrain()

            inst:ForceFacePoint(data.pos)

            inst.AnimState:PlayAnimation(inst.defensive_mode and "bellyflop_block_pre" or "bellyflop_pre")
            inst.AnimState:PushAnimation("bellyflop", false)

            local duration = 17 * FRAMES
            inst.sg.statemem.speed = math.clamp((data.pos - inst:GetPosition()):Length() / duration, 0.1, 24)
            inst.sg.statemem.pos = data.pos

            -- inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/jump")

            inst.SoundEmitter:PlaySound("grotto/creatures/centipede/aoe")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.moving then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                ToggleOffCharacterCollisions(inst)

                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                inst.sg.statemem.moving = true

                inst:SetEyeFlame(0)
            end),

            TimeEvent(20 * FRAMES, function(inst)
                DoLeapPound(inst)
                ToggleOnCharacterCollisions(inst)

                inst.sg.statemem.moving = false
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RestartBrain()
            -- inst:SetEyeFlame(1)
            inst:SetEyeFlame(0)
        end,
    },

    State {
        name = "taunt1",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline = {
            TimeEvent(10 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/taunt")

                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/taunt1")
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/taunt2")
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/taunt3")

                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/destroy3", "destroy3")


                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/hurt")
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")

                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/taunt")


                ShakeRoar(inst)
            end),

            TimeEvent(24 * FRAMES, PlayChestPoundSounds),
            TimeEvent(28 * FRAMES, PlayChestPoundSounds),
            TimeEvent(32 * FRAMES, PlayChestPoundSounds),

            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("destroy3")
            end),

            TimeEvent(36 * FRAMES, PlayChestPoundSounds),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("destroy3")
        end
    },

    State {
        name = "taunt2",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2")
        end,

        timeline = {
            TimeEvent(8 * FRAMES, DoTauntPound1),
            TimeEvent(11 * FRAMES, DoTauntPound1),
            TimeEvent(14 * FRAMES, DoTauntPound1),
            TimeEvent(24 * FRAMES, DoTauntPound2),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "enter_defensive_mode",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("block_pre")
        end,

        timeline = {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/chain_hit")
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "leave_defensive_mode",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("block_pst")
        end,

        timeline = {},

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "death_pre",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stun_loop", true)

            inst:SetMusicLevel(1)

            inst.sg.statemem.fx = inst:SpawnChild("stariliad_boss_guardian_glitch_fx", inst)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0)

            inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric", "electric")

            inst.sg:SetTimeout(3)
        end,

        timeline = {
            TimeEvent(1 * FRAMES, function(inst)
                local explode = inst:SpawnChild("stariliad_boss_guardian_explode_small_fx")
                explode.entity:AddFollower()
                explode.Follower:FollowSymbol(inst.GUID, "head", 0, 275, 0)

                -- local smokes = inst:SpawnChild("stariliad_small_explode_blue_particle")
                -- smokes.entity:AddFollower()
                -- smokes.Follower:FollowSymbol(inst.GUID, "head", 0, 0, 0)


                -- inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
                inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")

                inst:SetEyeFlame(0)
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/glitch_loop", "glitch_loop")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("death")
        end,

        onexit = function(inst)
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:KillFX()
            end

            inst.SoundEmitter:KillSound("electric")
        end
    },

    State {
        name = "death",
        tags = { "busy", "dead" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")

            RemovePhysicsColliders(inst)

            inst.sg.statemem.fires = {}
        end,

        timeline = {
            TimeEvent(0, function(inst)
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/death")
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/taunt2", "roar_before_explode")

                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/glitch_loop", "roar_before_explode")

                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/hurt")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")

                ShakePound(inst)
            end),

            TimeEvent(13 * FRAMES, function(inst)
                local pos = inst:GetPosition()
                pos.y = pos.y + 4
                inst.components.lootdropper:DropLoot(pos)

                inst.AnimState:HideSymbol("horns")

                inst:SetEyeFlame(0)
                inst:TurnOffLight()

                ShakePound(inst)

                local explode = inst:SpawnChild("stariliad_boss_guardian_explode_large_fx")
                explode.entity:AddFollower()
                explode.Follower:FollowSymbol(inst.GUID, "head", 0, 0, 0)

                local particle = inst:SpawnChild("stariliad_guardian_explode_particle")
                particle.entity:AddFollower()
                particle.Follower:FollowSymbol(inst.GUID, "head", 0, 0, 0)

                local fire_offsets = {
                    Vector3(0, 0, 0),
                    Vector3(-24, 10, 0),
                    Vector3(15, -10, 0),
                }
                local fire_remove_t = 6

                for _, v in pairs(fire_offsets) do
                    local fire = inst:SpawnChild("stariliad_guardian_death_fire_particle")
                    fire.entity:AddFollower()
                    fire.Follower:FollowSymbol(inst.GUID, "head", v.x + 24, v.y - 124, v.z)
                    fire:DoTaskInTime(fire_remove_t, fire.Remove)
                end

                local smoke = inst:SpawnChild("stariliad_smoke_trail")
                smoke.entity:AddFollower()
                smoke.Follower:FollowSymbol(inst.GUID, "head", 24, -124, 0)
                smoke:DoTaskInTime(fire_remove_t + 3, smoke.Remove)

                inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "fire")
                inst.SoundEmitter:SetParameter("fire", "intensity", 1)

                inst:DoTaskInTime(fire_remove_t, function()
                    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
                    inst.SoundEmitter:KillSound("fire")
                end)

                -- inst.SoundEmitter:KillSound("roar_before_explode")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/death2")
            end),

            TimeEvent(43 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")
                ShakePound(inst)
            end),

            TimeEvent(62 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/chain_hit")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")

                inst.AnimState:HideSymbol("chest")

                ShakePound(inst)
            end),

            TimeEvent(92 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

                -- inst:SetBluePower(false)

                inst._flash_event:push()
            end),

            TimeEvent(110 * FRAMES, function(inst)
                inst.Light:Enable(false)
            end),


            -- MakePowerOnOffLines(93 * FRAMES, FRAMES, 8),
        },
    },
}

CommonStates.AddIdle(states,
    nil,
    function(inst)
        return inst.defensive_mode and "block_loop" or "idle_loop"
    end,
    {
        TimeEvent(0 * FRAMES, function(inst)
            if inst.defensive_mode and inst.sg.mem.enter_defensive_mode then
                inst.sg:GoToState("enter_defensive_mode")
            end
            inst.sg.mem.enter_defensive_mode = nil
        end),
    }
)

CommonStates.AddHitState(states,
    {
        TimeEvent(0 * FRAMES, function(inst)
            if inst.defensive_mode then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")
                inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/chain_hit")
            else
                -- inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/hit")
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/guardian/hurt")
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/bonehit2")
                -- inst.SoundEmitter:PlaySound("grotto/creatures/centipede/hit_react")
            end
        end),

        TimeEvent(10 * FRAMES, function(inst)
            if inst.defensive_mode and inst.sg.mem.enter_defensive_mode then
                inst.sg:GoToState("enter_defensive_mode")
            end
            inst.sg.mem.enter_defensive_mode = nil
        end),
    },
    function(inst)
        return inst.defensive_mode and "block_hit" or "hit"
    end
)


CommonStates.AddRunStates(states, {
    runtimeline = {
        TimeEvent(5 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),

        TimeEvent(15 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),
    },

    endtimeline = {
        TimeEvent(2 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),

        TimeEvent(4 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),
    },
})

CommonStates.AddWalkStates(states, {
    walktimeline = {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
        end),

        TimeEvent(15 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),

    },
    endtimeline = {
        TimeEvent(7 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/step")
            ShakeIfClose(inst)
        end),
    },
})

-------------------------------------------------------------------------------
local function AddDoublePunchState(states, name, onenter, timeline)
    local nxt_states_map = {
        attack1 = "attack2",
        attack2 = "attack1b",
        attack1b = "attack2",
    }

    local pst_anims_map = {
        attack1 = "attack1_pst",
        attack2 = "attack2_pst",
        attack1b = "attack1_pst",
    }

    local state = State {
        name = name,
        tags = { "attack", "busy" },

        onenter = function(inst, data)
            data = data or {}

            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()

            inst.AnimState:PlayAnimation(name)

            if data.target and data.target:IsValid() then
                inst.sg.statemem.target = data.target
                inst:ForceFacePoint(data.target:GetPosition())
            end

            inst.sg.statemem.count = data.count or 0
            inst.sg.statemem.uppercut = data.uppercut

            if onenter then
                onenter(inst)
            end
        end,

        timeline = timeline or {},

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1

                -- To avoid combat:CanAttack() error
                inst.sg:RemoveStateTag("busy")
                if inst.sg.statemem.count > 0 then
                    inst.components.combat:ResetCooldown()
                end

                local target = inst.sg.statemem.target
                if not inst.components.combat:CanAttack(target) then
                    if not inst.components.combat.target then
                        inst.components.combat:TryRetarget()
                    end
                    target = inst.components.combat.target
                end

                local nxt_state = nil
                if inst.sg.statemem.count == 1 and name == "attack2" and inst.sg.statemem.uppercut then
                    nxt_state = "attack3"
                else
                    nxt_state = nxt_states_map[name]
                end

                print("target:", target)
                print("nxt_state:", nxt_state)
                -- print("CanAttack:", inst.components.combat:CanAttack(target))

                if inst.sg.statemem.count <= 0 or nxt_state == nil then
                    local pst_anim = pst_anims_map[name]
                    if pst_anim then
                        inst.AnimState:PlayAnimation(pst_anim)
                        inst.sg:GoToState("idle", true)
                    else
                        inst.sg:GoToState("idle")
                    end
                else
                    inst.sg:GoToState(nxt_state, {
                        target = target,
                        count = inst.sg.statemem.count,
                        uppercut = inst.sg.statemem.uppercut
                    })
                end
            end),
        },
    }

    table.insert(states, state)
end

AddDoublePunchState(states,
    "attack1",
    function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/swipe")
    end,
    {
        TimeEvent(6 * FRAMES, DoPunchAttack),
    }
)

AddDoublePunchState(states,
    "attack2",
    function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/swipe")
    end,
    {
        TimeEvent(7 * FRAMES, DoPunchAttack),
    }
)

AddDoublePunchState(states,
    "attack1b",
    function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/swipe")
    end,
    {
        TimeEvent(7 * FRAMES, DoPunchAttack),
    }
)

return StateGraph("SGstariliad_boss_guardian", states, events, "idle")
