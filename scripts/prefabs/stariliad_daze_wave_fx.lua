local ARC_TEXTURE = "fx/stariliad_arc.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "stariliad_daze_wave_colourenvelope"
local SCALE_ENVELOPE_NAME = "stariliad_daze_wave_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARC_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,    IntColour(0, 100, 250, 0) },
        { 0.25, IntColour(0, 100, 255, 100) },
        { 0.9,  IntColour(0, 100, 255, 100) },
        { 1,    IntColour(0, 100, 255, 0) },
    })

    local arc_max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { arc_max_scale * 0.25, arc_max_scale * 0.25 } },
            { 1, { arc_max_scale, arc_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 3

local function emit_arc_fn(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = pos:Get()

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
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

    --ARC
    effect:SetRenderResources(0, ARC_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local arc_desired_pps_low = 5
    local arc_desired_pps_high = 50
    local low_per_tick = arc_desired_pps_low * tick_time
    local high_per_tick = arc_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move * 6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_arc_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("stariliad_daze_wave_fx", fn, assets)
