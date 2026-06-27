require("stategraphs/commonstates")

local events =
{

}

local states =
{
    State {
        name = "land",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("land")

            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/ribs/step_wires")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/rust")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("open")
            end),
        },
    },

    State {
        name = "open",
        tags = { "busy", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("open")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst._light_data:set(1)
            end),

            TimeEvent(14 * FRAMES, function(inst)

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
        name = "idle",
        tags = { "idle", },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("green_loop")

            inst._light_data:set(0)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()

            local cant_have_tags = { "INLIMBO", "wall" }
            if inst.player_placed then
                table.insert(cant_have_tags, "player")
            else
                table.insert(cant_have_tags, "stariliad_space_pirate")
            end

            local ents = TheSim:FindEntities(x, y, z, 3.5, { "_combat", "_health" }, cant_have_tags)
            for _, v in pairs(ents) do
                if not IsEntityDeadOrGhost(v, true) then
                    inst.sg:GoToState("active")
                    break
                end
            end
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst._light_data:set(1)
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
        name = "active",
        tags = { "busy", },

        onenter = function(inst, duration)
            inst.AnimState:PlayAnimation("red_loop", true)

            inst._light_data:set(2)

            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/active_LP", "boom_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/electro")

            inst.sg:SetTimeout(duration or 0.8)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("explode")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("boom_loop")
        end,
    },

    State {
        name = "explode",
        tags = { "busy", "explode" },

        onenter = function(inst)
            inst.persists = false

            SpawnAt("stariliad_laser_ring", inst, { 0.85, 0.85, 0.85 })
            SpawnAt("stariliad_laser_explosion", inst, { 0.85, 0.85, 0.85 })

            ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.5, 0.03, 0.5, inst, 40)

            local effected_map = {}
            local x, y, z = inst.Transform:GetWorldPosition()

            local victims = TheSim:FindEntities(x, y, z, 3.5, { "_combat", "_health" }, { "INLIMBO" })
            for k, v in pairs(victims) do
                if not IsEntityDeadOrGhost(v, true) and v.components.combat and v.components.combat:CanBeAttacked(inst) then
                    SpawnPrefab("deerclops_laserhit"):SetTarget(v)
                    effected_map[v] = inst:DoTaskInTime(GetRandomMinMax(0.1, 0.3), function()
                        if not IsEntityDeadOrGhost(v, true) and v.components.combat and v.components.combat:CanBeAttacked(inst) then
                            inst.components.combat:DoAttack(v, nil, nil, nil, nil, math.huge)
                        end
                    end)
                end
            end

            local constructions = TheSim:FindEntities(x, y, z, 3.5, nil, { "INLIMBO" },
                { "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable" })
            for k, v in pairs(constructions) do
                if not effected_map[v] and v.components.workable and v.components.workable:CanBeWorked() then
                    SpawnPrefab("deerclops_laserhit"):SetTarget(v)
                    effected_map[v] = inst:DoTaskInTime(GetRandomMinMax(0.1, 0.3), function()
                        if v:IsValid() and v.components.workable and v.components.workable:CanBeWorked() then
                            v.components.workable:WorkedBy(inst, 25)
                        end
                    end)
                end
            end

            local bombs = TheSim:FindEntities(x, y, z, 3.5, { "stariliad_hulk_bomb" }, { "INLIMBO" })
            for k, v in pairs(bombs) do
                if v.sg:HasStateTag("idle") then
                    SpawnPrefab("deerclops_laserhit"):SetTarget(v)
                    v.sg:GoToState("active", GetRandomMinMax(0.1, 0.5))
                elseif not v.sg:HasStateTag("explode") then
                    v.sg:GoToState("explode")
                end
            end


            inst._light_data:set(0)

            inst:Hide()

            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/smash_2", nil, 0.75)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/hulk_metal_robot/smash_3")

            inst.sg:SetTimeout(3)
        end,

        ontimeout = function(inst)
            inst:Remove()
        end,
    },
}



return StateGraph("SGstariliad_hulk_bomb_placed", states, events, "idle")
