require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
}

local function return_to_idle(inst)
    inst.sg:GoToState("idle")
end

local function targetinrange(inst)
    -- local scandist = inst:GetScannerScanDistance()
    local scandist = 4
    local scandist_sq = scandist * scandist
    local scantarget = inst.components.entitytracker:GetEntity("scantarget")
    return scantarget ~= nil and inst:GetDistanceSqToInst(scantarget) < scandist_sq or nil
end

local states =
{
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:PlayAnimation(targetinrange(inst) and "scan_loop" or "idle", true)
        end,

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },
}

--states, timelines, anims, softstop, delaystart, fns
CommonStates.AddWalkStates(states, nil,
    {
        startwalk = function(inst)
            if targetinrange(inst) then
                return "scan_loop"
            else
                return "walk_pre"
            end
        end,
        walk = function(inst)
            if targetinrange(inst) then
                return "scan_loop"
            else
                return "walk_loop"
            end
        end,
        stopwalk = function(inst)
            if targetinrange(inst) then
                return "scan_loop"
            else
                return "walk_pst"
            end
        end,
    })

return StateGraph("SGstariliad_space_pirate_probe", states, events, "idle")
