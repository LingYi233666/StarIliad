local TEXTURE = "fx/torchfire.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "stariliad_guardian_death_fire_firecolourenvelope"
local SCALE_ENVELOPE_NAME = "stariliad_guardian_death_fire_firescaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,   IntColour(187, 111, 60, 128) },
            { .49, IntColour(187, 111, 60, 128) },
            { .5,  IntColour(255, 255, 0, 128) },
            { .51, IntColour(255, 30, 56, 128) },
            { .75, IntColour(255, 30, 56, 128) },
            { 1,   IntColour(255, 7, 28, 0) },
        }
    )

    local max_scale = 6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { max_scale, max_scale } },
            { 1, { max_scale * .25, max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local FIRE_MAX_LIFETIME = .3

local function emit_fire_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = FIRE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

--------------------------------------------------------------------------

local function common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -----------------------------------------------------

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --FIRE
    effect:SetRenderResources(0, TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, FIRE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    -- effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    return inst
end

local function guardian_death_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    -----------------------------------------------------

    local effect = inst.VFXEffect

    local fire_num_particles_to_emit = 1

    -- local sphere_emitter = StarIliadMath.CustomSphereEmitter(0, 0.5, 0, 90 * DEGREES, 0, TWOPI)

    local sphere_emitter = CreateSphereEmitter(0.2)

    EmitterManager:AddEmitter(inst, nil, function()
        --FIRE
        while fire_num_particles_to_emit > 1 do
            emit_fire_fn(effect, sphere_emitter)
            fire_num_particles_to_emit = fire_num_particles_to_emit - 1
        end
        fire_num_particles_to_emit = fire_num_particles_to_emit + 1
    end)

    -- print("stariliad_guardian_death_fire_particle inst:", inst)
    return inst
end
-- ThePlayer:SpawnChild("stariliad_guardian_death_fire_particle")
return Prefab("stariliad_guardian_death_fire_particle", guardian_death_fn, assets)
