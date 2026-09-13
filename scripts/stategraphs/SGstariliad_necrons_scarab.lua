require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "burrow"),
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnLocomote(false, true),

    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            local melee_range = inst.components.combat:GetHitRange()
            inst.sg:GoToState(
                data.target:IsValid()
                and not inst:IsNear(data.target, melee_range)
                and "leap_attack" --Do leap attack
                or "attack",
                data.target
            )
        end
    end),
}

local states =
{
    State {
        name = "burrow",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("burrow")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/burrow", "move")
                inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/pebble_crab/burrow")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()

                if inst:IsValid() then
                    inst.sg:GoToState("underground")
                end
            end),
        },

        onexit = function(inst)
            if inst.SoundEmitter:PlayingSound("move") then
                inst.SoundEmitter:KillSound("move")
            end
        end,
    },

    State {
        name = "underground",
        tags = { "busy", "nointerrupt", "invisible", "underground" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst:Hide()
            inst.DynamicShadow:Enable(false)
            inst:AddTag("notarget")
            RemovePhysicsColliders(inst)
        end,

        onexit = function(inst)
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst:RemoveTag("notarget")
            ChangeToCharacterPhysics(inst, 10, .5)
        end,
    },

    State {
        name = "emerge",
        tags = { "busy", "invisible" },

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)

            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/burrow", "move")
            -- inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_emerge")
            inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/pebble_crab/emerge")

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("unburrow")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.9, .2))

            if inst.components.combat.target ~= nil then
                inst:ForceFacePoint(inst.components.combat.target:GetPosition())
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                if inst.components.combat.target ~= nil then
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                end
            end),
            TimeEvent(32 * FRAMES, function(inst) inst.DynamicShadow:Enable(true) end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            if inst.SoundEmitter:PlayingSound("move") then
                inst.SoundEmitter:KillSound("move")
            end
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.DynamicShadow:Enable(true)
        end,
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            if inst.components.combat.target ~= nil then
                inst:ForceFacePoint(inst.components.combat.target:GetPosition())
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/necrons_scarab/taunt")
            end),

            -- TimeEvent(8 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/taunt")
            --  end),

        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst:PerformBufferedAction() then
                    inst.sg:GoToState("eat_loop")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "eat_loop",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1 + math.random() * 1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "eat_pst")
        end,
    },

    State {
        name = "leap_attack",
        tags = { "attack", "canrotate", "busy", "jumping" },

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("leap_attack")
            inst.sg.statemem.target = target

            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target:GetPosition())
            end

            inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/necrons_scarab/leap_attack", "buzz")
        end,

        timeline =
        {
            -- TimeEvent(7 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/necrons_scarab/leap_attack", "buzz")
            -- end),

            -- TimeEvent(7 * FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/fly_LP", "buzz")
            -- end),

            TimeEvent(7 * FRAMES, function(inst)
                inst:AddTag("flying")
            end),

            TimeEvent(11 * FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(20, 0, 0)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("buzz")
                -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/idle")

                -- local fx=ThePlayer:SpawnChild("stariliad_tomb_building_dust_small") fx:DoTaskInTime(0.2, inst.Remove)
                local tile_type = inst:GetCurrentTileType()
                if tile_type == WORLD_TILES.STARILIAD_ASH then
                    local fx = inst:SpawnChild("stariliad_tomb_building_dust_small")
                    fx:DoTaskInTime(1, fx.Remove)
                end
            end),

            TimeEvent(18 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst:RemoveTag("flying")

                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                -- if math.random() < 0.5 then
                --     inst.sg:GoToState("taunt")
                -- else
                --     inst.sg:GoToState("idle")
                -- end
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("flying")

            inst.SoundEmitter:KillSound("buzz")
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,
    },
}

CommonStates.AddIdle(states, nil, "idle", {
    TimeEvent(10 * FRAMES, function(inst)
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/idle")
    end),
})

CommonStates.AddWalkStates(states, {
    walktimeline = {
        TimeEvent(0 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/walk")
        end),
        TimeEvent(3 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/walk")
        end),
        TimeEvent(6 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/walk")
        end),
    },
})

CommonStates.AddCombatStates(states, {
    -- timeline
    hittimeline = {
        TimeEvent(0 * FRAMES, function(inst)
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/hit")
            -- inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_mech_med_sharp")
            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/necrons_scarab/hit")
        end),
    },

    attacktimeline = {
        TimeEvent(8 * FRAMES, function(inst)
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),

        TimeEvent(10 * FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)
        end),
    }
}, {
    -- anims
    attack = "attack",
}, {
    -- fns
    deathenter = function(inst)
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/weevole/death")
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/necrons_scarab/death")


        inst:DoTaskInTime(inst.components.health.destroytime or 2, function()
            inst.light_fade_t = GetTime()
            inst.components.updatelooper:AddOnUpdateFn(function()
                local duration = 1
                local cur_t = GetTime() - inst.light_fade_t
                if cur_t >= duration then
                    return
                end

                local percent = cur_t / duration
                inst.Light:SetRadius(0.67 * (1 - percent))
            end)
        end)
    end,
}, {
    -- data
})

CommonStates.AddFrozenStates(states)

return StateGraph("SGstariliad_necrons_scarab", states, events, "idle", actionhandlers)
