require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.STARILIAD_BLOB_RETURN, "action"),
}

local events =
{
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("moving")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),

}

local states =
{
    State {
        name = "spawn",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("blob_pre_med")

            if data and data.vel then
                inst:ForceFacePoint(inst:GetPosition() + data.vel)

                inst.sg.statemem.speed = data.vel:Length()
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > 1e-6 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline = {
            TimeEvent(17 * FRAMES, function(inst)
                inst.sg.statemem.speed = 0
                inst.Physics:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },

    State {
        name = "despawn",
        tags = { "busy" },

        onenter = function(inst)
            inst.persists = false

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("blob_attach_middle_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State {
        name = "moving",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("blob_idle_med", true)
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)

            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State {
        name = "action",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst:PerformBufferedAction() then
                inst.sg:GoToState("despawn")
            else
                inst.sg:GoToState("idle", true)
            end
        end,
    },
}

CommonStates.AddIdle(states, nil, "blob_idle_med", {
    TimeEvent(0 * FRAMES, function(inst)
        local mainblob = inst.components.entitytracker:GetEntity("mainblob")
        if not (mainblob and mainblob:IsValid() and not mainblob.components.health:IsDead() and inst:IsNear(mainblob, 40)) then
            inst.sg:GoToState("despawn")
        end
    end),
})

return StateGraph("SGstariliad_boss_gorgoroth_blob", states, events, "idle", actionhandlers)
