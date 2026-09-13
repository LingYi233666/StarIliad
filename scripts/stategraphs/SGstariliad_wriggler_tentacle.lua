require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnLocomote(true, false),

    EventHandler("attacked", function(inst, data)
        if inst.components.health and not inst.components.health:IsDead() then
            if (not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("moving")) or inst.sg:HasAnyStateTag("caninterrupt", "frozen") then
                inst.sg:GoToState("hit")
            end
        end
    end),
}

local function EmergeWithWorms(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.STARILIAD_WRIGGLER_TENTACLE_EMERGE_HIT_RANGE,
        { "_combat", "_health" }, { "INLIMBO", "tentacle" })

    for _, v in ipairs(ents) do
        if inst.components.combat:CanTarget(v) and not inst.components.combat:IsAlly(v) then
            if v.components.inventory then
                local curse = SpawnAt("stariliad_curse_toad_parasite_infect", v)
                if StarIliadBasic.ForceGiveItem(v, curse) then
                    v:PushEvent("attacked", { attacker = inst, damage = 0 })
                elseif curse:IsValid() then
                    curse:Remove()
                end
            end

            inst.components.combat:DoAttack(v, nil, nil, nil, nil, math.huge)
        end
    end

    SpawnAt("stariliad_boss_toad_parasite_worms_fx", inst)

    inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/toad_parasite/tentacle_pop")
end

local states = {
    State {
        name = "after_attack",
        tags = { "busy", "canrotate", "should_physics" },

        onenter = function(inst, data)
            data = data or {}

            inst.AnimState:PlayAnimation("atk_idle", true)

            inst.sg:SetTimeout(data.duration or 2)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("into_underground")
        end,
    },

    State {
        name = "into_underground",
        tags = { "busy", "should_physics" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("atk_pst")
            if data and data.speed then
                inst.AnimState:SetDeltaTimeMultiplier(data.speed)
            end
        end,

        timeline = {
            TimeEvent(28 * FRAMES, function(inst)
                SpawnAt("stariliad_wriggler_tentacle_move_fx", inst)
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "attack",
        tags = { "attack", "busy", "should_physics" },

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:SetDeltaTimeMultiplier(3)

            inst.components.combat:StartAttack()

            SpawnAt("stariliad_wriggler_tentacle_move_fx", inst)
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                EmergeWithWorms(inst)
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("into_underground")
                end
            end),
        },
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("into_underground", { speed = 1.6 })
                end
            end),
        },
    },


    State {
        name = "attack_dash",
        tags = { "attack", "busy", "attack_dash", "should_physics" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.Physics:SetMotorVel(8, 0, 0)

            if data.start_pos == nil then
                EmergeWithWorms(inst)
            end

            inst.sg.statemem.start_pos = data.start_pos or inst:GetPosition()
            inst.sg.statemem.stop_time = data.stop_time or math.huge
            inst.sg.statemem.max_dist = data.max_dist or math.huge
            if data.face_pos then
                inst:ForceFacePoint(data.face_pos:Get())
            end
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVel(8, 0, 0)
        end,

        timeline = {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, TUNING.STARILIAD_WRIGGLER_TENTACLE_DASH_HIT_RANGE, nil, nil,
                    nil, { "INLIMBO", "tentacle" })
            end),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, TUNING.STARILIAD_WRIGGLER_TENTACLE_DASH_HIT_RANGE, nil, nil,
                    nil, { "INLIMBO", "tentacle" })
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if GetTime() >= inst.sg.statemem.stop_time
                        or (inst:GetPosition() - inst.sg.statemem.start_pos):Length() > inst.sg.statemem.max_dist then
                        inst.sg:GoToState("into_underground")
                    else
                        inst.sg:GoToState("attack_dash", {
                            start_pos = inst.sg.statemem.start_pos,
                            stop_time = inst.sg.statemem.stop_time,
                            max_dist = inst.sg.statemem.max_dist,
                        })
                    end
                end
            end),
        },
    },

    --  State {
    --     name = "attack_dash_prepare",
    --     tags = { "busy", "attack_dash_prepare", "dash_prepare_moving", "should_physics" },

    --     onenter = function(inst, data)
    --         inst.AnimState:PlayAnimation("breach_pre")
    --         inst.AnimState:PushAnimation("breach_loop", true)

    --         inst.sg.statemem.prepare_pos = data.prepare_pos
    --         inst.sg.statemem.prepare_time = data.prepare_time
    --         inst.sg.statemem.start_prepare_time = GetTime()
    --         inst.sg.statemem.dash_data_fn = data.dash_data_fn
    --     end,

    --     onupdate = function(inst)
    --         inst:ForceFacePoint(inst.sg.statemem.prepare_pos:Get())

    --         if (inst:GetPosition() - inst.sg.statemem.prepare_pos):Length() <= 1 then
    --             if not inst.AnimState:IsCurrentAnimation("breach_pst") then
    --                 inst.AnimState:PlayAnimation("breach_pst")

    --                 inst.sg:RemoveStateTag("dash_prepare_moving")
    --                 inst:CheckSG()
    --             end
    --             inst.Physics:Stop()
    --         else
    --             inst.Physics:SetMotorVel(12, 0, 0)
    --         end

    --         if (GetTime() - inst.sg.statemem.start_prepare_time) >= inst.sg.statemem.prepare_time then
    --             inst.Physics:Stop()
    --             if not inst.should_disappear and inst.components.combat.target then
    --                 inst.sg:GoToState("attack_dash", inst.sg.statemem.dash_data_fn(inst))
    --             else
    --                 inst.sg:GoToState("attack")
    --             end
    --         end
    --     end,

    --     onexit = function(inst)
    --         inst.Physics:Stop()
    --     end,
    -- },
}

CommonStates.AddIdle(states, nil, "idle")

local function RunOnUpdate(inst)
    -- SpawnAt("stariliad_wriggler_tentacle_move_fx", inst).AnimState:SetTime(10 * FRAMES)
    SpawnAt("stariliad_wriggler_tentacle_move_fx", inst)
end

CommonStates.AddRunStates(states, nil, {
    startrun = "breach_pre",
    run = "breach_loop",
    stoprun = "breach_pst",
}, nil, nil, {
    -- startonupdate = RunOnUpdate,
    -- runonupdate = RunOnUpdate,
    -- stoponupdate = RunOnUpdate,
})

CommonStates.AddDeathState(states)


return StateGraph("SGstariliad_wriggler_tentacle", states, events, "idle")
