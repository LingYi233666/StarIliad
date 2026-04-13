local assets = {

}

local warning_configs = {
    {
        sound = nil,
        volume = 1,
        shaking = {
            -- mode, duration, speed, scale
            CAMERASHAKE.FULL, 0.74, 0.025, 0.28,
        },
    },

    {
        sound = nil,
        volume = 1,
        shaking = {
            -- mode, duration, speed, scale
            CAMERASHAKE.FULL, 0.74, 0.025, 0.28,
        },
    },

    {
        sound = nil,
        volume = 1,
        shaking = {
            -- mode, duration, speed, scale
            CAMERASHAKE.FULL, 0.74, 0.025, 0.28,
        },
    },
}

local function ClientFn(sound, volume, shaking)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst:DoTaskInTime(0, function()
        if ThePlayer and ThePlayer:IsValid() then
            inst.entity:SetParent(TheFocalPoint.entity)

            if sound then
                inst.SoundEmitter:PlaySound(sound, "warning")

                if volume then
                    inst.SoundEmitter:SetVolume("warning", volume)
                end
            end

            if shaking then
                -- CAMERASHAKE.FULL, .7, .02, .2, inst, 40
                -- ThePlayer:ShakeCamera(mode, duration, speed, scale, source_or_pt, maxDist)
                ThePlayer:ShakeCamera(unpack(shaking))
            end
        end
    end)

    inst:DoTaskInTime(3, inst.Remove)

    return inst
end

local function MakeWarning(name, sound, volume, shaking)
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
                    local ent = ClientFn(sound, volume, shaking)
                    -- ent.Transform:SetPosition(x, y, z)
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
    table.insert(t, MakeWarning("stariliad_ice_meteor_erupt_warning_lv" .. lvl, data.sound, data.volume, data.shaking))
end
return unpack(t)
