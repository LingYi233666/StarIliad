require("stategraphs/commonstates")


local events =
{
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack",
        function(inst)
            if not inst.components.health:IsDead()
                and not inst.sg:HasStateTag("busy")
                and not inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("hop", { target = inst.components.combat.target })
            end
        end),
    -- CommonHandlers.OnSleep(),
    -- CommonHandlers.OnFreeze(),

    EventHandler("locomote",
        function(inst)
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then
                return
            end

            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("hopping") then
                    inst.sg:GoToState("idle")
                end
            else
                if not inst.sg:HasStateTag("hopping") then
                    if inst:CheckHopCooldown() then
                        inst.sg:GoToState("hop")
                    elseif not inst.sg:HasStateTag("idle") then
                        inst.sg:GoToState("idle")
                    end
                end
            end
        end),

    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if not inst.sg:HasAnyStateTag("busy", "attack", "hopping") and not CommonHandlers.HitRecoveryDelay(inst) then
                inst.sg:GoToState("hit")
            end
        end
    end),
}

local states =
{
    State {
        name = "hop",
        tags = { "moving", "canrotate", "hopping" },

        onenter = function(inst, data)
            inst.last_hop_time = GetTime()

            data = data or {}

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk2", false)

            -- Has target, means this is an attack hop
            if data.target and data.target:IsValid() then
                inst.sg.statemem.target = data.target

                inst.sg:AddStateTag("attack")
                inst.sg:AddStateTag("abouttoattack")
                inst.sg:AddStateTag("busy")

                inst.components.combat:StartAttack()

                inst:ForceFacePoint(data.target.Transform:GetWorldPosition())

                -- print("Do attack hop to", data.target)
            end

            if data.standstill then
                inst.sg.statemem.standstill = data.standstill
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)
                if inst.sg.statemem.standstill then
                    inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/voice")
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh")
                end
            end),

            TimeEvent(1 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/atk_2_fly")
            end),

            TimeEvent(5 * FRAMES, function(inst)
                if not inst.sg.statemem.standstill then
                    local target = inst.sg.statemem.target
                    if target then
                        inst.Physics:SetMotorVel(inst.components.locomotor.runspeed, 0, 0)
                    else
                        inst.components.locomotor:RunForward()
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/summon")
                else
                    inst.Physics:Stop()
                end

                inst.sg:AddStateTag("no_absorb_blob")
            end),

            TimeEvent(7 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/atk_2_VO")
            end),

            TimeEvent(10 * FRAMES, function(inst)
                -- inst.sg:AddStateTag("noattack")
                -- inst.sg:AddStateTag("iframeskeepaggro")
            end),

            TimeEvent(21 * FRAMES, function(inst)
                -- inst.sg:RemoveStateTag("noattack")
                -- inst.sg:RemoveStateTag("iframeskeepaggro")

                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/land")
            end),

            TimeEvent(24 * FRAMES, function(inst)
                inst:SpawnTrails()
                inst:DoPoundDamage()
                inst:ShakeItems(6)

                inst.Physics:Stop()

                -- ShakeAllCameras(CAMERASHAKE.FULL, 1.2, .03, .7, inst, 30)
                -- ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 1, inst, 40)

                -- mode, duration, speed, scale, source_or_pt, maxDist
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 0.5, inst, 76)

                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")

                inst.sg:RemoveStateTag("abouttoattack")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("no_absorb_blob")

                inst.sg:AddStateTag("idle")
            end),
        },

        ontimeout = function(inst)
            inst.Physics:Stop()
            inst.sg:GoToState("idle")
        end,
    },

    State {
        name = "roar",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/taunt")
                inst.components.epicscare:Scare(5)
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
        name = "spit",
        tags = { "busy" },

        onenter = function(inst, data)
            data = data or {}
            if data.pos_queue == nil or #data.pos_queue == 0 then
                inst.sg:GoToState("idle")
                return
            end

            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("atk1")

            inst.sg.statemem.pos = table.remove(data.pos_queue, 1)
            inst.sg.statemem.pos_queue = data.pos_queue

            if not (inst.sg.statemem.pos.IsVector3 and inst.sg.statemem.pos:IsVector3()) then
                -- print("Reset pos:", inst.sg.statemem.pos)
                inst.sg.statemem.pos = Vector3(inst.sg.statemem.pos.Transform:GetWorldPosition())
            end
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/atk_1_rumble")
            end),

            TimeEvent(18 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/atk_1_pre")
            end),

            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/atk_1")
                -- inst.SoundEmitter:PlaySound("rifts4/goop/spit_out")

                local meteor = SpawnAt("stariliad_boss_gorgoroth_meteor", inst.sg.statemem.pos)
                meteor.owner = inst
                meteor:StartMeteor(
                    TUNING.GORGOROTH_METEOR_LANDING_DURATION - TUNING.GORGOROTH_METEOR_LANDING_WARNING_DURATION,
                    TUNING.GORGOROTH_METEOR_LANDING_WARNING_DURATION
                )
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if #inst.sg.statemem.pos_queue == 0 then
                    inst.sg:GoToState("idle")
                else
                    inst.sg:GoToState("spit", { pos_queue = inst.sg.statemem.pos_queue })
                end
            end),
        },
    },

    -- TODO: Add a hollow knight style boss explode SG ?
    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {

            TimeEvent(6 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/death")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short")
            end),
            TimeEvent(6 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .2)

                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .3)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .4)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .5)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .6)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(26 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode", nil, .7)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(28 * FRAMES, function(inst)
                -- inst.SoundEmitter:PlaySound(
                --     "stariliad_sfx/prefabs/gorgoroth/explode")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
            end),
            TimeEvent(43 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/land")
            end),

        },
    },


}

CommonStates.AddIdle(states, nil, "idle")
-- CommonStates.AddFrozenStates(states)
CommonStates.AddHitState(states, {
    TimeEvent(0 * FRAMES, function(inst)
        -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/gorgoroth/hit")
        -- inst.SoundEmitter:PlaySound("rifts4/goop/hit_big")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/hit")
    end),
})

return StateGraph("SGstariliad_boss_gorgoroth", states, events, "idle")
