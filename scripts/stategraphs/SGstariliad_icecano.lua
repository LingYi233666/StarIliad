require("stategraphs/commonstates")

local events =
{
    EventHandler("start_erupt", function(inst, data)

    end),
}

local states =
{
    State {
        name = "dormant_idle",
        tags = { "idle", },

        onenter = function(inst)
            if inst.AnimState:IsCurrentAnimation("active_idle") or
                inst.AnimState:IsCurrentAnimation("erupt") or
                inst.AnimState:IsCurrentAnimation("rumble")
            then
                inst.AnimState:PlayAnimation("active_idle_pst")
                inst.AnimState:PushAnimation("dormant_idle_pre", false)
                inst.AnimState:PushAnimation("dormant_idle", true)
            else
                inst.AnimState:PlayAnimation("dormant_idle", true)
            end
        end,
    },

    State {
        name = "active_idle",
        tags = { "idle", },

        onenter = function(inst)
            if inst.AnimState:IsCurrentAnimation("dormant_idle") then
                inst.AnimState:PlayAnimation("dormant_idle_pst")
                inst.AnimState:PushAnimation("active_idle_pre", false)
                inst.AnimState:PushAnimation("active_idle", true)
            elseif inst.AnimState:IsCurrentAnimation("erupt") then
                inst.AnimState:PushAnimation("active_idle", true)
            else
                inst.AnimState:PlayAnimation("active_idle", true)
            end
        end,
    },

    State {
        name = "rumble",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("rumble")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst:ShouldActive() then
                    inst.sg:GoToState("active_idle")
                else
                    inst.sg:GoToState("dormant_idle")
                end
            end),
        },
    },

    State {
        name = "erupt_pre",
        tags = { "busy", },

        onenter = function(inst)
            if inst.AnimState:IsCurrentAnimation("dormant_idle") then
                inst.AnimState:PlayAnimation("dormant_idle_pst")
                inst.AnimState:PushAnimation("active_idle_pre", false)
            elseif inst.AnimState:PlayAnimation("dormant_idle_pst") then
                local t = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("dormant_idle_pst")
                inst.AnimState:SetTime(t)
                inst.AnimState:PushAnimation("active_idle_pre", false)
            else
                inst.sg:GoToState("erupt")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("erupt")
                end
            end),
        },
    },

    State {
        name = "erupt",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("erupt")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:IsErupting() then
                        inst.sg:GoToState("erupt")
                    elseif inst:ShouldActive() then
                        inst.sg:GoToState("active_idle")
                    else
                        inst.sg:GoToState("dormant_idle")
                    end
                end
            end),
        },
    },
}



return StateGraph("SGstariliad_icecano", states, events, "dormant_idle")
