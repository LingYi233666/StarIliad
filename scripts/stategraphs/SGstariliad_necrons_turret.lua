require("stategraphs/commonstates")

local events =
{
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst)
        if not inst.components.health:IsDead() and ((inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute")) or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack")
        end
    end),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnElectrocute(),
    --CommonHandlers.OnAttacked(),
    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if CommonHandlers.TryElectrocuteOnAttacked(inst, data) then
                return
            elseif not inst.sg:HasAnyStateTag("attack", "electrocute") then
                inst.sg:GoToState("hit")
            end
        end
    end),
}

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst)
            inst:SyncAnim("idle_loop", true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst:SyncAnim("death")

            inst.components.lootdropper:DropLoot()

            RemovePhysicsColliders(inst)
        end,

        timeline =
        {
            TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/pop") end)
        },
    },

    State {
        name = "hit",
        tags = { "hit" },

        onenter = function(inst)
            inst:SyncAnim("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "attack",
        tags = { "attack", "canrotate" },
        onenter = function(inst)
            inst:TriggerLight()
            inst:SyncAnim("atk")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/charge")
        end,
        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst:SpawnOpenFireFX()
            end),

            TimeEvent(22 * FRAMES, function(inst)
                inst.components.combat:StartAttack()
                -- inst.components.combat:DoAttack()
                local target = inst.components.combat.target
                if target and target:IsValid() then
                    -- inst:LaunchProjectile(target)
                    local target_pos = target:GetPosition()
                    local aim_pos = target:GetPosition()
                    if target:HasTag("character") then
                        aim_pos.y = aim_pos.y + 1.5
                    elseif target:HasTag("smallcreature") then
                        aim_pos.y = aim_pos.y + 0.5
                    elseif target:HasTag("largecreature") then
                        aim_pos.y = aim_pos.y + 1.7
                    end
                    inst:LaunchLaserServer(aim_pos)
                    inst:DoDamage(target_pos)
                end
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shoot")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddFrozenStates(states)
CommonStates.AddElectrocuteStates(states)

return StateGraph("SGstariliad_necrons_turret", states, events, "idle")
