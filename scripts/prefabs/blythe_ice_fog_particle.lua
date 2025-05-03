local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME = "blythe_ice_fog_colourenvelope"
local SCALE_ENVELOPE_NAME = "blythe_ice_fog_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,   IntColour(255, 247, 255, 0) },
        { 0.1, IntColour(255, 239, 255, 90) },
        { .3,  IntColour(255, 239, 255, 150) },
        { .52, IntColour(255, 239, 255, 90) },
        { 1,   IntColour(255, 239, 255, 0) },
    })

    -- local sparkle_max_scale = .4
    local sparkle_max_scale = .3

    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = TUNING.BLYTHE_ICE_FOG_LIFE_TIME

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local ang_vel = (UnitRand() - 1) * 10

    effect:AddRotatingParticle(
        0,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
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

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 6)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, .16)
    effect:SetFollowEmitter(0, true)

    -----------------------------------------------------


    local sphere_emitter = CreateSphereEmitter(.3)
    -- local sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        local time_alive = inst:GetTimeAlive()

        if time_alive > FRAMES and time_alive < 3 * FRAMES then
            for i = 1, 5 do
                emit_smoke_fn(effect, sphere_emitter)
            end

            -- emit_smoke_fn(effect, sphere_emitter)
        end
    end)

    return inst
end

return Prefab("blythe_ice_fog_particle", fn, assets)
