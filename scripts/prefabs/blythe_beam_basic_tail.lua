local ARROW_TEXTURE = resolvefilepath("fx/spark.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local ARROW_COLOUR_ENVELOPE_NAME = "blythe_beam_basic_tail_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "blythe_beam_basic_tail_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 150, 2, 25) },
            { .075, IntColour(255, 193, 5, 200) },
            { .3,   IntColour(255, 193, 5, 255) },
            { .6,   IntColour(255, 193, 50, 255) },
            { .9,   IntColour(255, 193, 161, 230) },
            { 1,    IntColour(255, 193, 175, 0) },
        }
    )

    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0,   { arrow_max_scale * 0.05, arrow_max_scale * 0.05 } },
            { 0.2, { arrow_max_scale * 0.2, arrow_max_scale * 1 } },
            { 1,   { arrow_max_scale * 0.001, arrow_max_scale * 0.2 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local ARROW_MAX_LIFETIME = 0.6

local function emit_arrow_fn(effect, pos, vel)
    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = vel:Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end
-- ThePlayer:SpawnChild("blythe_beam_basic_tail")
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

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
    effect:SetMaxNumParticles(0, 25)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, 0.1)
    effect:SetRotateOnVelocity(0, true)

    inst.last_pos = nil

    local sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not parent then
            return
        end

        if inst.last_pos == nil or (parent:GetPosition() - inst.last_pos):Length() >= 1 then
            local vel = StarIliadBasic.GetFaceVector(parent)
            emit_arrow_fn(effect, Vector3(sphere_emitter()), vel * GetRandomMinMax(0.25, 0.33))

            inst.last_pos = parent:GetPosition()
        end
    end)

    return inst
end

return Prefab("blythe_beam_basic_tail", fn, assets)
