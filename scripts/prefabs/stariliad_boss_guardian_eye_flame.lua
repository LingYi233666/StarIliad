local ADD_SHADER = "shaders/vfx_particle.ksh"

local SMOKE_TEXTURE = "fx/smoke.tex"
local COLOUR_ENVELOPE_NAME_BLUE = "stariliad_boss_guardian_eye_flame_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_RED = "stariliad_boss_guardian_eye_flame_red_colourenvelope"
local SCALE_ENVELOPE_NAME = "stariliad_boss_guardian_eye_flame_scaleenvelope"


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
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_RED, {
        { 0,    IntColour(255, 15, 15, 0) },
        { 0.01, IntColour(255, 12, 12, 250) },
        -- { .8,   IntColour(255, 10, 10, 255) },
        { 1,    IntColour(255, 10, 10, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_BLUE, {
        -- { 0,    IntColour(0, 100, 248, 0) },
        -- { 0.01, IntColour(0, 148, 248, 50) },
        -- { 0.8,  IntColour(0, 148, 248, 255) },
        -- { 1,    IntColour(0, 100, 248, 0) },


        { 0,    IntColour(131, 204, 248, 0) },
        { 0.01, IntColour(131, 210, 248, 50) },
        { 0.8,  IntColour(131, 210, 248, 255) },
        { 1,    IntColour(131, 200, 248, 0) },
    })


    local smoke_max_scale = 2.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,   { smoke_max_scale, smoke_max_scale } },
            { .3,  { smoke_max_scale * .9, smoke_max_scale * .9 } },
            { .55, { smoke_max_scale * .6, smoke_max_scale * .6 } },
            { 1,   { smoke_max_scale * .4, smoke_max_scale * .4 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.5
local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
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


local function common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    -- if InitEnvelope ~= nil and not TheNet:IsDedicated() then
    --     InitEnvelope()
    -- end

    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --normal
    effect:SetRenderResources(0, SMOKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    -- effect:SetBlendMode(0, BLENDMODE.Additive)

    -- effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetFollowEmitter(0, true)

    -----------------------------------------------------


    local sphere_emitter = CreateSphereEmitter(.05)

    local num_to_emit = 0
    EmitterManager:AddEmitter(inst, nil, function()
        num_to_emit = num_to_emit + 1
        while num_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    -- inst:ListenForEvent("onremove", function()
    --     inst.VFXEffect:ClearAllParticles(0)
    -- end)

    return inst
end

local function fn_red()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_RED)

    return inst
end

local function fn_blue()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_BLUE)

    return inst
end

return Prefab("stariliad_boss_guardian_eye_flame_red", fn_red, assets),
    Prefab("stariliad_boss_guardian_eye_flame_blue", fn_blue, assets)
