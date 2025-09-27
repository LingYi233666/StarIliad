require("stategraphs/commonstates")

local function hit_recovery_skip_cooldown_fn(inst, last_t, delay)
    return inst.components.combat:InCooldown() and inst.sg:HasStateTag("idle")
end

local events =
{
    CommonHandlers.OnAttacked(nil, 2, hit_recovery_skip_cooldown_fn),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnDeath(),

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
        if (facing_angle == nil or StarIliadBasic.GetFaceAngle(inst, v) <= facing_angle * 0.5) and inst:IsNear(v, range + v:GetPhysicsRadius(0)) then
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
            TimeEvent(0, function(inst)

            end),

            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/taunt")
                ShakeRoar(inst)
            end),

            TimeEvent(24 * FRAMES, PlayChestPoundSounds),
            TimeEvent(28 * FRAMES, PlayChestPoundSounds),
            TimeEvent(32 * FRAMES, PlayChestPoundSounds),
            TimeEvent(36 * FRAMES, PlayChestPoundSounds),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
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
                inst.SoundEmitter:PlaySound("dontstarve/forge2/beetletaur/hit")
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

local function MakePowerOnOffLines(start_t, dt, counts)
    local timeline = {}

    for i = 1, counts do
        table.insert(timeline,
            TimeEvent(start_t + dt * (i * 2 - 2), function(inst)
                inst:SetBluePower(true)
            end)
        )
        table.insert(timeline,
            TimeEvent(start_t + dt * (i * 2 - 1), function(inst)
                inst:SetBluePower(false)
            end)
        )
    end

    return unpack(timeline)
end

CommonStates.AddDeathState(states,
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/boarrior/death")
            ShakePound(inst)
        end),

        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")

            inst.AnimState:HideSymbol("horns")

            inst:SetEyeFlame(0)
            inst:TurnOffLight()
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

            inst:SetBluePower(false)
        end),

        MakePowerOnOffLines(93 * FRAMES, FRAMES, 8)
    }
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
