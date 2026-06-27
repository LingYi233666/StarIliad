require("stategraphs/commonstates")

local actionhandlers =
{
    -- ActionHandler(ACTIONS.GOHOME, "gohome"),
    -- ActionHandler(ACTIONS.EAT, "eat"),
    -- ActionHandler(ACTIONS.CHOP, "chop"),

    ActionHandler(ACTIONS.STARILIAD_PLACE_BOMB, "pickup"),
}


local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnHop(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    -- CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if not inst.sg:HasAnyStateTag("busy", "attack", "hopping") then
                if inst.shield_percent and inst.components.health:GetPercent() > inst.shield_percent then
                    inst:SpawnChild("stariliad_space_pirate_solider_shield_full_fx")
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/hide_hit")
                else
                    inst.sg:GoToState("hit")
                end
            end
        end
    end),

    EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or
                (inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute"))
            )
        then
            if (inst.can_use_attack2 and math.random() < 0.5) or inst:HasDebuff("stariliad_debuff_pirate_high_speed") then
                inst.sg:GoToState("attack2")
            else
                inst.sg:GoToState("attack")
            end
        end
    end),
}

local states =
{
    -------------------------------------- Emotions --------------------------------------

    State {
        name = "emote_angry",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("idle_angry", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")

            inst.sg:SetTimeout(GetRandomMinMax(2, 5))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State {
        name = "emote_creepy",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("idle_creepy", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")

            inst.sg:SetTimeout(GetRandomMinMax(2, 5))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State {
        name = "emote_happy",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("idle_happy", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")

            inst.sg:SetTimeout(GetRandomMinMax(2, 5))
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State {
        name = "emote_abandon",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("abandon")

            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/abandon")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")

            local target = inst.components.combat.target
            if target then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    -- State {
    --     name = "emote_alert",
    --     tags = { "idle", "canrotate" },

    --     onenter = function(inst)
    --         inst.Physics:Stop()

    --         inst.AnimState:PlayAnimation("alert_pre")
    --         inst.AnimState:PushAnimation("alert", true)

    --         -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/alert", "alert")
    --         inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/alert_LP", "alert", 0.5)

    --         inst.sg:SetTimeout(GetRandomMinMax(2, 5))
    --     end,


    --     timeline =
    --     {
    --         TimeEvent(3, function(inst)
    --             inst.SoundEmitter:KillSound("alert")
    --         end),
    --     },

    --     ontimeout = function(inst)
    --         inst.sg:GoToState("idle", "alert_pst")
    --     end,

    --     onexit = function(inst)
    --         inst.SoundEmitter:KillSound("alert")
    --     end
    -- },

    State {
        name = "emote_alert",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert", false)

            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/alert", "alert")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/alert_LP", "alert", 0.5)
        end,


        timeline =
        {
            TimeEvent(3, function(inst)
                inst.SoundEmitter:KillSound("alert")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", "alert_pst")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("alert")
        end
    },

    State {
        name = "emote_hungry",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("hungry")

            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    ------------------------------------------------------------------------------

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("atk")

            inst.components.combat:StartAttack()

            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/attack")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),

            TimeEvent(13 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "attack2",
        tags = { "attack", "busy" },

        onenter = function(inst)
            local is_high_speed = inst:HasDebuff("stariliad_debuff_pirate_high_speed")
            if not is_high_speed then
                inst.components.locomotor:StopMoving()
            else
                inst.components.locomotor:RunForward()
            end

            inst.AnimState:PlayAnimation("atk2")

            inst.components.combat:StartAttack()

            inst.sg.statemem.is_high_speed = is_high_speed

            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/attack")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
            end),

            TimeEvent(13 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.is_high_speed then
                    inst.components.locomotor:StopMoving()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.is_high_speed then
                inst.components.locomotor:StopMoving()
            end
        end,
    },

    State {
        name = "chop",
        tags = { "chopping" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}


CommonStates.AddIdle(states, nil, function(inst)
    -- if inst.components.combat.target then
    --     return "idle_angry"
    -- end

    return "idle_loop"
end)

CommonStates.AddWalkStates(states,
    {
        walktimeline = {
            TimeEvent(0 * FRAMES, PlayFootstep),
            TimeEvent(12 * FRAMES, PlayFootstep),
        },
    }
)

CommonStates.AddRunStates(states,
    {
        runtimeline = {
            TimeEvent(0 * FRAMES, PlayFootstep),
            TimeEvent(10 * FRAMES, PlayFootstep),
        },
    }
)

CommonStates.AddSleepStates(states,
    {
        sleeptimeline =
        {
            TimeEvent(35 * FRAMES,
                function(inst)
                    --  inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/sleep")
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/sleep")
                end),
        },
    }
)


CommonStates.AddSimpleState(states,
    "refuse",
    "pig_reject",
    { "busy" },
    nil,
    nil,
    {
        onenter = function(inst)
            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/reject")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/reject")
        end,
    }
)
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, { "busy" })

CommonStates.AddHopStates(states, false, { pre = "run_pre", loop = "run_loop", pst = "run_pst" })

CommonStates.AddHitState(states,
    {
        TimeEvent(0 * FRAMES, function(inst)
            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/hit")
        end),
    }
)

CommonStates.AddDeathState(states,
    {
        -- TimeEvent(0 * FRAMES, function(inst)
        --     inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/death")
        -- end),
    },
    nil,
    {
        deathenter = function(inst)
            -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_solider/death")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/death")
        end,
    }
)

return StateGraph("SGstariliad_space_pirate_solider", states, events, "idle", actionhandlers)
