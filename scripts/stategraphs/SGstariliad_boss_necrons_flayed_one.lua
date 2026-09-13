require("stategraphs/commonstates")


local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
    CommonHandlers.OnAttacked(),
    EventHandler("doattack", function(inst)
        if inst.sg:HasStateTag("busy") or inst.components.health:IsDead() then
            return
        end

        inst.sg:GoToState("attack")
    end),
}

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .15, inst, 30)
end

local function DoFoleySounds(inst, volume)
    -- inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/chain_foley", nil, volume)
end

local function DoFootstep(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/step", nil, volume)
    ShakeIfClose(inst)
end

local function DoBodyfall(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bodyfall")
    ShakeIfClose(inst)
end

local function DoSwipeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/swipe")
end

local function DoChompShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1.5, .015, inst.enraged and .2 or .1, inst, 20)
end

local function DoRoarAlert(inst)
    inst.components.epicscare:Scare(5)
end

local function DoLanding(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/step")
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, inst.enraged and .2 or .1, inst, 30)
end

local states =
{
    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_doubleclaw")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
        end,

        timeline =
        {
            TimeEvent(FRAMES, DoFoleySounds),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(13 * FRAMES, DoSwipeSound),
            TimeEvent(14 * FRAMES, DoFoleySounds),
            TimeEvent(16 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(23 * FRAMES, DoSwipeSound),
            TimeEvent(24 * FRAMES, DoFoleySounds),
            TimeEvent(27 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            CommonHandlers.OnNoSleepTimeEvent(40 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State {
        name = "attack_chomp",
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_chomp")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.jump then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/attack_3")
            end),
            TimeEvent(6 * FRAMES, DoChompShake),
            TimeEvent(7 * FRAMES, DoRoarAlert),
            TimeEvent(26 * FRAMES, function(inst)
                inst.sg.statemem.jump = true
                inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            end),
            TimeEvent(33 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bite")
            end),
            TimeEvent(34 * FRAMES, DoLanding),
            TimeEvent(35 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil then
                    inst.components.combat:SetRange(inst.chomp_hit_range)
                    inst.components.combat:DoAttack(inst.sg.statemem.target)
                    inst.components.combat:SetRange(inst.attack_range, inst.hit_range)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                inst.sg.statemem.jump = nil
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            end),
            -- CommonHandlers.OnNoSleepTimeEvent(49 * FRAMES, function(inst)
            --     local target = inst.components.combat.target
            --     if target ~= nil and
            --         target:IsValid() and
            --         target:IsNear(inst, inst.attack_range + target:GetPhysicsRadius(0)) then
            --         inst.sg:GoToState("quickattack")
            --     else
            --         inst.sg:RemoveStateTag("busy")
            --         inst.sg:RemoveStateTag("nosleep")
            --         inst.sg:RemoveStateTag("nofreeze")
            --     end
            -- end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },
}

CommonStates.AddIdle(states, nil, nil, {
    TimeEvent(8 * FRAMES, function(inst)
        DoFoleySounds(inst, .25)
    end),
    TimeEvent(27 * FRAMES, function(inst)
        DoFoleySounds(inst, .2)
    end),
})

CommonStates.AddWalkStates(states,
    {
        starttimeline =
        {
            TimeEvent(8 * FRAMES, DoFoleySounds),
            TimeEvent(9 * FRAMES, DoFootstep),
        },
        walktimeline =
        {
            TimeEvent(20 * FRAMES, DoFoleySounds),
            TimeEvent(21 * FRAMES, DoFootstep),
            TimeEvent(44 * FRAMES, DoFoleySounds),
            TimeEvent(45 * FRAMES, DoFootstep),
        },
        endtimeline =
        {
            TimeEvent(0, function(inst)
                DoFoleySounds(inst)
                DoFootstep(inst, .6)
            end),
            TimeEvent(10 * FRAMES, DoFoleySounds),
        },
    })


CommonStates.AddHitState(states, {
    TimeEvent(0, DoFoleySounds),
    TimeEvent(12 * FRAMES, function(inst)
        DoFoleySounds(inst)
        DoFootstep(inst, .6)
    end),
})

CommonStates.AddDeathState(states, {
    TimeEvent(FRAMES, DoFoleySounds),
    TimeEvent(3 * FRAMES, function(inst)
        DoBodyfall(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/death")
    end),
    TimeEvent(23 * FRAMES, DoFoleySounds),
    TimeEvent(25 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/klaus/bodyfall_dirt")
        ShakeIfClose(inst)
    end),
    TimeEvent(27 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
    end),
})

return StateGraph("SGstariliad_boss_necrons_flayed_one", states, events, "idle")
