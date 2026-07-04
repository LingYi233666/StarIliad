require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}


local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            -- inst._light_enable:set(inst.AnimState:IsCurrentAnimation("scan_loop"))

            local anim = inst:ShouldScan() and "scan_loop" or "idle"
            if inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("hit_turn_off_pre")

            -- inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_mech_med_sharp")
        end,

        timeline = {
            TimeEvent(0.2, function(inst)
                inst.AnimState:PlayAnimation("idle")
                inst.AnimState:SetTime(0.46)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("idle") then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            -- inst.AnimState:SetDeltaTimeMultiplier(6)
            inst.AnimState:PlayAnimation("hit_turn_off_pre")

            inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_mech_med_sharp")
            inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/space_pirate_probe/death")

            inst.sg.statemem.fx = SpawnPrefab("stariliad_enemy_die_smoke_black")
            inst.sg.statemem.fx:SetTarget(inst)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "body", 0, 0, 0)

            inst.sg.statemem.velocity = 0
            inst.sg.statemem.resistance = FRAMES * 8

            local lastattacker = inst.components.combat.lastattacker
            local lastattackedtime = inst.components.combat:GetLastAttackedTime()

            if lastattacker and lastattacker:IsValid() and lastattackedtime and GetTime() - lastattackedtime < 1 then
                inst.sg.statemem.velocity = GetRandomMinMax(10, 13)
                inst:FaceAwayFromPoint(lastattacker:GetPosition(), true)
                inst.Physics:SetMotorVel(inst.sg.statemem.velocity, 0, 0)
            end

            inst.sg:SetTimeout(30 * FRAMES)
        end,

        onupdate = function(inst)
            -- local vel = Vector3(inst.Physics:GetMotorVel())
            -- vel = vel:GetNormalized() * math.max(vel:Length() - inst.sg.statemem.resistance, 0)

            -- if vel:Length() < 0.01 then
            --     inst.Physics:Stop()
            -- else
            --     inst.Physics:SetMotorVel(vel.x, 0, vel.z)
            -- end

            inst.sg.statemem.velocity = math.max(inst.sg.statemem.velocity - inst.sg.statemem.resistance, 0)

            if inst.sg.statemem.velocity < 0.01 then
                inst.Physics:Stop()
            else
                inst.Physics:SetMotorVel(inst.sg.statemem.velocity, 0, 0)
            end
        end,

        timeline = {
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg.statemem.resistance = FRAMES * 15
            end),
        },

        ontimeout = function(inst)
            -- SpawnAt("blythe_missile_explode_fx", inst)
            SpawnAt("explode_small", inst)
            SpawnAt("stariliad_space_pirate_probe_burntground", inst)
            inst:Remove()
        end,

        onexit = function(inst)
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
        end
    },
}

--states, timelines, anims, softstop, delaystart, fns
CommonStates.AddWalkStates(states, nil,
    {
        startwalk = function(inst)
            if inst:ShouldScan() then
                return "scan_loop"
            else
                return "walk_pre"
            end
        end,
        walk = function(inst)
            if inst:ShouldScan() then
                return "scan_loop"
            else
                return "walk_loop"
            end
        end,
        stopwalk = function(inst)
            if inst:ShouldScan() then
                return "scan_loop"
            else
                return "walk_pst"
            end
        end,
    }
)

return StateGraph("SGstariliad_space_pirate_probe", states, events, "idle")
