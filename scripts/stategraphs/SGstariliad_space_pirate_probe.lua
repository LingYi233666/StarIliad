require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
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

            inst.AnimState:PlayAnimation(inst:IsTargetInRange() and "scan_loop" or "idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

--states, timelines, anims, softstop, delaystart, fns
CommonStates.AddWalkStates(states, nil,
    {
        startwalk = function(inst)
            if inst:IsTargetInRange() then
                return "scan_loop"
            else
                return "walk_pre"
            end
        end,
        walk = function(inst)
            if inst:IsTargetInRange() then
                return "scan_loop"
            else
                return "walk_loop"
            end
        end,
        stopwalk = function(inst)
            if inst:IsTargetInRange() then
                return "scan_loop"
            else
                return "walk_pst"
            end
        end,
    }
)

return StateGraph("SGstariliad_space_pirate_probe", states, events, "idle")
