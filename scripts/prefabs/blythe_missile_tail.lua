local FIRE_TEXTURE = "fx/torchfire.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_FIRE = "blythe_missile_tail_fire_colourenvelope"
local SCALE_ENVELOPE_NAME_FIRE = "blythe_missile_tail_fire_scaleenvelope"

local COLOUR_ENVELOPE_NAME_ARROW = "blythe_missile_tail_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "blythe_missile_tail_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", FIRE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),

    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_FIRE,
        {
            { 0,   IntColour(187, 111, 60, 128) },
            { .49, IntColour(187, 111, 60, 128) },
            { .5,  IntColour(255, 255, 0, 128) },
            { .51, IntColour(255, 30, 56, 128) },
            { .75, IntColour(255, 30, 56, 128) },
            { 1,   IntColour(255, 7, 28, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            { 0,    IntColour(255, 150, 2, 25) },
            { .075, IntColour(255, 193, 5, 200) },
            { .3,   IntColour(255, 193, 5, 255) },
            { .6,   IntColour(255, 193, 50, 255) },
            { .9,   IntColour(255, 193, 161, 230) },
            { 1,    IntColour(255, 193, 175, 0) },
        }
    )

    local fire_max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_FIRE,
        {
            { 0, { fire_max_scale * .5, fire_max_scale } },
            { 1, { fire_max_scale * .5 * .5, fire_max_scale * .5 } },
        }
    )

    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0,   { arrow_max_scale * 0.05, arrow_max_scale * 0.05 } },
            { 0.2, { arrow_max_scale * 0.2, arrow_max_scale * 1 } },
            { 1,   { arrow_max_scale * 0.001, arrow_max_scale * 0.2 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local FIRE_MAX_LIFETIME = 0.3
local ARROW_MAX_LIFETIME = 0.2

local function emit_fire_fn(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = FIRE_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_arrow_fn(effect, pos, velocity)
    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
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
    effect:InitEmitters(2)

    effect:SetRenderResources(0, FIRE_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, FIRE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FIRE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FIRE)
    effect:SetBlendMode(0, BLENDMODE.Additive) -- Premultiplied
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)
    effect:SetDragCoefficient(0, 0.1)

    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 25)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetRotateOnVelocity(1, true)
    effect:SetDragCoefficient(1, 0.1)

    -----------------------------------------------------
    inst.last_pos = nil

    local sphere_emitter_fire = CreateSphereEmitter(.05)
    local sphere_emitter_arrow = CreateSphereEmitter(.03)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local forward = StarIliadBasic.GetFaceVector(parent)


        local spawn_center_fire = -forward * 0.25
        local velocity_fire = -forward * 0.05
        local offset_fire = Vector3(sphere_emitter_fire())

        emit_fire_fn(effect, spawn_center_fire + offset_fire, velocity_fire)

        -----------------------------------------------------
        if inst.last_pos == nil or (parent:GetPosition() - inst.last_pos):Length() >= 0.1 then
            local spawn_center_arrow = -forward * 0
            local velocity_arrow = forward * GetRandomMinMax(0.25, 0.33)
            local offset_arrow = Vector3(sphere_emitter_arrow())

            emit_arrow_fn(effect, spawn_center_arrow + offset_arrow, velocity_arrow)

            inst.last_pos = parent:GetPosition()
        end
    end)

    return inst
end

return Prefab("blythe_missile_tail", fn, assets)
