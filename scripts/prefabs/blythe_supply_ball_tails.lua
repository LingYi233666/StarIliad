local SMOKE_TEXTURE = "fx/smoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_TAIL_BLUE = "blythe_supply_ball_tail_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_TAIL_RED = "blythe_supply_ball_tail_red_colourenvelope"


local SCALE_ENVELOPE_NAME_TAIL = "blythe_supply_ball_tail_scaleenvelope"
local SCALE_ENVELOPE_NAME_TAIL_SMALL = "blythe_supply_ball_tail_small_scaleenvelope"

local assets =
{
    Asset("IMAGE", SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_TAIL_BLUE, {
        { 0,   IntColour(96, 249, 255, 0) },
        { 0.1, IntColour(96, 249, 255, 150) },
        -- { 0.6, IntColour(96, 249, 255, 180) },
        { 1,   IntColour(96, 249, 255, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_TAIL_RED, {
        { 0,   IntColour(200, 25, 25, 0) },
        { 0.1, IntColour(200, 25, 25, 150) },
        -- { 0.6, IntColour(200, 25, 25, 180) },
        { 1,   IntColour(200, 25, 25, 0) },
    })

    local sparkle_max_scale = .4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_TAIL,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            -- { 0.6, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .1, sparkle_max_scale * .1 } },
        }
    )

    sparkle_max_scale = .2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_TAIL_SMALL,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            -- { 0.6, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .1, sparkle_max_scale * .1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.6

local function emit_smoke_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local vx, vy, vz = 0, 0, 0

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25

    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        0,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        uv_offset, 0    -- uv offset
    )
end

local function common_fn()
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
    effect:SetRenderResources(0, SMOKE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local num_to_emit = 2

    local sphere_emitter = CreateSphereEmitter(0.1)

    EmitterManager:AddEmitter(inst, nil, function()
        while num_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end

        num_to_emit = 2
    end)

    return inst
end


local function blue_fn()
    local inst = common_fn()

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_TAIL_BLUE)
    inst.VFXEffect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_TAIL)

    return inst
end

local function red_fn()
    local inst = common_fn()

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_TAIL_RED)
    inst.VFXEffect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_TAIL)

    return inst
end

return Prefab("blythe_supply_ball_tail_blue", blue_fn, assets),
    Prefab("blythe_supply_ball_tail_red", red_fn, assets)
