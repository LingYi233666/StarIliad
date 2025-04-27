local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_ARROW = "blythe_speed_burst_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "blythe_speed_burst_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(255, 255, 150, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 255, 150, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 255, 150, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,   IntColour(255, 255, 150, 0) },
        { 0.1, IntColour(255, 255, 150, 255) },
        { 1,   IntColour(255, 255, 150, 0) },
    })

    local sparkle_max_scale = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .1, sparkle_max_scale * 0.5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.5

local function emit_sparkle_fn(effect, cylinder_emitter, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = cylinder_emitter()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

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
    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    -- effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local cylinder_emitter = StarIliadMath.CreateCylinderEmitter(0, 0.33, 0.3, 2)
    local num_to_emit = 1

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local forward = StarIliadBasic.GetFaceVector(parent)
        local velocity = forward * 0.05

        while num_to_emit > 0 do
            emit_sparkle_fn(effect, cylinder_emitter, velocity)

            num_to_emit = num_to_emit - 1
        end

        num_to_emit = num_to_emit + 0.5
    end)

    return inst
end

return Prefab("blythe_speed_burst_particle", fn, assets)
