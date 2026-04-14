local assets = {

}

local warning_configs = {
    -- ["small"] = { duration = 0.7 / 2, speed = 0.02, scale = 0.75 / 2 },
    -- ["med"] = { duration = 0.7, speed = 0.02, scale = 0.75 },
    -- ["large"] = { duration = 2 * 0.7, speed = 0.02, scale = 2 * 0.75 },

    {
        duration = 1.3,
        speed = 0.02,
        scale = 0.75 / 2,
    },

    {
        duration = 2.0,
        speed = 0.02,
        scale = 0.75,
    },

    {
        duration = 2.5,
        speed = 0.02,
        scale = 2 * 0.75,
    }

    -- {
    --     sound = nil,
    --     volume = 1,
    --     shaking = {
    --         -- mode, duration, speed, scale
    --         CAMERASHAKE.FULL, 0.7 / 2, 0.02, 0.75 / 2,
    --     },
    -- },

    -- {
    --     sound = nil,
    --     volume = 1,
    --     shaking = {
    --         -- mode, duration, speed, scale
    --         CAMERASHAKE.FULL, 0.7, 0.02, 0.75,
    --     },
    -- },

    -- {
    --     sound = nil,
    --     volume = 1,
    --     shaking = {
    --         -- mode, duration, speed, scale
    --         CAMERASHAKE.FULL, 2 * 0.7, 0.02, 2 * 0.75,
    --     },
    -- },
}

local function ClientFn(duration, speed, scale)
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst:DoTaskInTime(0, function()
        if ThePlayer and ThePlayer:IsValid() then
            if TheFocalPoint then
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "stariliad_ice_meteor_erupt_warning")
                TheFocalPoint.SoundEmitter:SetParameter("stariliad_ice_meteor_erupt_warning", "intensity", 0.08)

                inst:DoTaskInTime(duration,
                    function()
                        TheFocalPoint.SoundEmitter:KillSound("stariliad_ice_meteor_erupt_warning")
                    end
                )
            end

            ThePlayer:ShakeCamera(CAMERASHAKE.FULL, duration, speed, scale)

            -- if sound then
            --     inst.SoundEmitter:PlaySound(sound, "warning")

            --     if volume then
            --         inst.SoundEmitter:SetVolume("warning", volume)
            --     end
            -- end

            -- if shaking then
            --     -- CAMERASHAKE.FULL, .7, .02, .2, inst, 40
            --     -- ThePlayer:ShakeCamera(mode, duration, speed, scale, source_or_pt, maxDist)
            --     ThePlayer:ShakeCamera(unpack(shaking))
            -- end
        end
    end)

    inst:DoTaskInTime(3, inst.Remove)

    return inst
end

local function MakeWarning(name, duration, speed, scale)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst._target = net_entity(inst.GUID, "inst._target", "targetdirty")

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("targetdirty", function()
                local target = inst._target:value()

                if target and target:IsValid() and ThePlayer == target then
                    -- local x, y, z = target.Transform:GetWorldPosition()
                    -- local ent = ClientFn(duration, speed, scale)
                    -- ent.Transform:SetPosition(x, y, z)


                    if TheWorld then
                        TheWorld.SoundEmitter:PlaySound("dontstarve/cave/earthquake",
                            "stariliad_ice_meteor_erupt_warning")
                        TheWorld.SoundEmitter:SetParameter("stariliad_ice_meteor_erupt_warning", "intensity", 1)

                        inst:DoTaskInTime(duration,
                            function()
                                TheWorld.SoundEmitter:KillSound("stariliad_ice_meteor_erupt_warning")
                            end
                        )
                    end

                    ThePlayer:ShakeCamera(CAMERASHAKE.FULL, duration, speed, scale)
                end
            end)
        end

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetTarget = function(inst, target)
            local x, y, z = target.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x, y, z)

            inst._target:set(target)
        end

        inst.persists = false


        inst:DoTaskInTime(3, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

-- local t = {}
-- for level, distance in ipairs(WARNING_LEVEL_DISTANCE) do
--     table.insert(t, Prefab("stariliad_ice_meteor_erupt_warning_lvl" .. level, makewarning(distance)))
-- end
-- return unpack(t)

local t = {}
for lvl, data in pairs(warning_configs) do
    table.insert(t, MakeWarning("stariliad_ice_meteor_erupt_warning_lv" .. lvl, data.duration, data.speed, data.scale))
end
return unpack(t)
