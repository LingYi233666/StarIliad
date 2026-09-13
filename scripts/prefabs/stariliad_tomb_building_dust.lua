local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_GREY = "stariliad_tomb_building_dust_grey_colourenvelope"

local SCALE_ENVELOPE_NAME = "stariliad_tomb_building_dust_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_GREY,
        {
            { 0,    IntColour(103, 103, 103, 0) },
            { 0.05, IntColour(103, 103, 103, 150) },
            { 0.33, IntColour(103, 103, 103, 125) },
            { 1,    IntColour(103, 103, 103, 0) },
        }
    )

    local glow_max_scale = 0.35
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,   { glow_max_scale * 0.5, glow_max_scale * 0.5 } },
            { .55, { glow_max_scale * 1, glow_max_scale * 1 } },
            { 1,   { glow_max_scale * 0.6, glow_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local GLOW_MAX_LIFETIME = 1.7

local function emit_grow_fn(effect, emitter_fn, angle_velocity)
    local vx, vy, vz = .005 * UnitRand(), GetRandomMinMax(0.0, 0.07), .005 * UnitRand()
    local lifetime = GLOW_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = emitter_fn()

    angle_velocity = angle_velocity or GetRandomMinMax(3, 5) * (math.random() <= 0.5 and 1 or -1)

    effect:AddRotatingParticle(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        angle_velocity       -- angle velocity
    )
end


local function client_one_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddNetwork()

    inst:AddTag("FX")

    -- inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    -- if TheNet:IsDedicated() then
    --     return inst
    -- elseif InitEnvelope ~= nil then
    --     InitEnvelope()
    -- end

    if InitEnvelope ~= nil then
        InitEnvelope()
    end


    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_GREY)
    effect:SetMaxNumParticles(0, 1)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, GLOW_MAX_LIFETIME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    -- effect:SetSortOrder(0, 1)
    -- effect:SetSortOffset(0, 1)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, 0.05)
    effect:SetAcceleration(0, 0, -0.03, 0)

    -- local sphere_emitter = CreateSphereEmitter(0.8)

    -- local sphere_emitter = StarIliadMath.CustomSphereEmitter(0.5, 0.8, 0, PI, 0, PI2)

    -- local sphere_emitter = StarIliadMath.CreateCylinderEmitter(0.5, 0.8, 0, 0.4)

    -- local num_to_emit = 1
    -- EmitterManager:AddEmitter(inst, nil, function()
    --     while num_to_emit > 1 do
    --         emit_grow_fn(effect, sphere_emitter, GetRandomMinMax(2, 3.5) * (math.random() <= 0.5 and 1 or -1))
    --         num_to_emit = num_to_emit - 1
    --     end

    --     num_to_emit = num_to_emit + GetRandomMinMax(0.6, 0.8)
    -- end)


    local sphere_emitter = CreateSphereEmitter(0)
    inst.num_to_emit = 0
    EmitterManager:AddEmitter(inst, nil, function()
        while inst.num_to_emit > 1 do
            emit_grow_fn(effect, sphere_emitter, GetRandomMinMax(2, 3.5) * (math.random() <= 0.5 and 1 or -1))
            inst.num_to_emit = inst.num_to_emit - 1
        end
        -- emit_grow_fn(effect, sphere_emitter, GetRandomMinMax(2, 3.5) * (math.random() <= 0.5 and 1 or -1))
    end)

    return inst
end

local function client_carrier_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end


local function small_on_update(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())

    while inst.num_to_emit >= 1 do
        local offset = Vector3(inst.sphere_emitter())
        local carrier = SpawnAt("stariliad_tomb_building_dust_client_carrier", pos, nil, offset)

        local dust = carrier:SpawnChild("stariliad_tomb_building_dust_small_client_one")
        dust.num_to_emit = 2

        inst.num_to_emit = inst.num_to_emit - 1
    end

    inst.num_to_emit = inst.num_to_emit + GetRandomMinMax(1, 1.5)
end

local function small_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    if not TheNet:IsDedicated() then
        inst.num_to_emit = 0
        inst.sphere_emitter = StarIliadMath.CreateCylinderEmitter(0.5, 1, 0, 0.4)

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(small_on_update)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("stariliad_tomb_building_dust_small_client_one", client_one_fn, assets),
    Prefab("stariliad_tomb_building_dust_client_carrier", client_carrier_fn),
    Prefab("stariliad_tomb_building_dust_small", small_fn)
