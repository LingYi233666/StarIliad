local SPARKLE_TEXTURE = "fx/rain.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_RAINDROP = "raindrop_colourenvelope"
local SCALE_ENVELOPE_NAME_RAINDROP = "raindrop_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_RAINDROP,
        {
            -- { 0, IntColour(255, 255, 255, 200) },
            -- { 1, IntColour(255, 255, 255, 200) },

            { 0, IntColour(255, 255, 255, 255) },
            { 1, IntColour(255, 255, 255, 255) },
        }
    )

    local max_scale = 10
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_RAINDROP,
        {
            { 0, { .1, max_scale } },
            { 1, { .1, max_scale } },

            -- { 0, { 1, 1 } },
            -- { 1, { 1, 1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 2
-- local MAX_PERSIST_TIME = 10
-- local MIN_NUM_DROPS = 20
-- local MAX_NUM_DROPS = 30
local MAX_PERSIST_TIME = 8
local MIN_NUM_DROPS = 15
local MAX_NUM_DROPS = 25
local GRAVITY = -9.8
-- local GRAVITY = 0

local function emit_rain_fn(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = MAX_LIFETIME
    local px, py, pz = pos:Get()

    effect:AddRotatingParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz, -- velocity
        0, 0        -- angle, angular_velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst:DoTaskInTime(MAX_PERSIST_TIME, inst.Remove)

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_RAINDROP)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_RAINDROP)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetSortOrder(0, 3)
    -- effect:SetDragCoefficient(0, .2)
    effect:EnableDepthTest(0, true)
    effect:SetAcceleration(0, 0, GRAVITY, 0)
    -----------------------------------------------------

    -- local box_emitter = CreateBoxEmitter(0, 20, 0, 1, 5, 1)
    local box_emitter = CreateBoxEmitter(0, 20, 0, 15, 10, 15)


    -- inst.num_to_emit = 0
    -- inst.num_to_emit_per_second = 1
    -- inst.last_update_time = GetTime()
    inst.emit_time = {}


    local num_drops = math.random(MIN_NUM_DROPS, MAX_NUM_DROPS)
    local step = MAX_PERSIST_TIME / num_drops
    for i = 0, num_drops do
        -- table.insert(inst.emit_time, GetTime() + math.random() * (MAX_PERSIST_TIME - FRAMES))

        local offset = StarIliadMath.NormalDistribution(0.5, 0.25) * MAX_PERSIST_TIME
        offset = math.clamp(offset, 0, MAX_PERSIST_TIME)
        table.insert(inst.emit_time, GetTime() + offset)

        -- local offset = math.clamp(step * i + UnitRand() * step * 0.5, 0, MAX_PERSIST_TIME - FRAMES)
        -- table.insert(inst.emit_time, GetTime() + offset)
    end
    table.insert(inst.emit_time, MAX_PERSIST_TIME - FRAMES)

    -- inst.emit_time = { FRAMES }
    table.sort(inst.emit_time, function(a, b)
        return a < b
    end)

    EmitterManager:AddEmitter(inst, nil, function()
        -- local dt = GetTime() - inst.last_update_time
        -- inst.last_update_time = GetTime()

        local t = inst.emit_time[1]
        if not t then
            return
        end

        if GetTime() >= t then
            table.remove(inst.emit_time, 1)
        else
            return
        end

        local parent = inst.entity:GetParent()
        if not parent or not ThePlayer or parent ~= ThePlayer then
            return
        end

        -- inst.num_to_emit = inst.num_to_emit + inst.num_to_emit_per_second * dt

        -- while inst.num_to_emit > 0 do
        --     inst.num_to_emit = inst.num_to_emit - 1
        -- end


        local pos_offset = Vector3(box_emitter())
        local height = pos_offset.y
        local y_speed_init = -2 - 8 * math.random()
        -- local velocity_init = Vector3FromTheta(math.random() * PI2, 0.1)
        local velocity_init = Vector3(0, 0, 0)
        velocity_init.y = y_speed_init


        local v0 = math.abs(y_speed_init) * 50 -- 50 is a fix factor
        local a = math.abs(GRAVITY)
        local h = math.max(0, height)          -- visual effect height
        local duration

        if a > 1e-6 then
            duration = (math.sqrt(v0 * v0 + 2 * a * h) - v0) / a
        else
            duration = h / v0
        end

        emit_rain_fn(effect, pos_offset, velocity_init)

        -- print("pos_offset:", pos_offset)
        -- print("height:", h)
        -- print("v0:", v0)
        -- print("a:", a)
        -- print("duration:", duration)


        parent:DoTaskInTime(duration, function()
            local pos_fx = pos_offset
            pos_fx.y = 0

            local fx = SpawnAt("raindrop", parent, nil, pos_fx)
            fx.AnimState:SetLightOverride(1)
            SpawnAt("stariliad_raindrop_click", parent, nil, pos_fx)
        end)
    end)

    return inst
end

local function click_fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddAnimState()

    -- inst.AnimState:SetBuild("raindrop")
    -- inst.AnimState:SetBank("raindrop")
    -- inst.AnimState:PlayAnimation("anim")

    -- inst:ListenForEvent("animover", OnAnimOver)

    -- inst.RestartFx = RestartFx

    inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/raindrop/click")
    end)

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

-- ThePlayer:SpawnChild("stariliad_raindrop_warning")
return Prefab("stariliad_raindrop_warning", fn, assets),
    Prefab("stariliad_raindrop_click", click_fn)
