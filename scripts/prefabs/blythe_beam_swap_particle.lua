local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE_BLUE = "blythe_beam_swap_segment_particle_colourenvelope_smoke_blue"
local COLOUR_ENVELOPE_NAME_SMOKE_YELLOW = "blythe_beam_swap_segment_particle_colourenvelope_smoke_yellow"
local COLOUR_ENVELOPE_NAME_ARROW = "blythe_beam_swap_segment_particle_colourenvelope_arrow"
local COLOUR_ENVELOPE_NAME_BLACK_SMOKE = "blythe_beam_swap_segment_particle_colourenvelope_black_smoke"

local SCALE_ENVELOPE_NAME_SMOKE_THIN = "blythe_beam_swap_segment_particle_scaleenvelope_smoke_thin"
local SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN = "blythe_beam_swap_segment_particle_scaleenvelope_smoke_very_thin"
local SCALE_ENVELOPE_NAME_SMOKE = "blythe_beam_swap_segment_particle_scaleenvelope_smoke"
local SCALE_ENVELOPE_NAME_ARROW = "blythe_beam_swap_segment_particle_scaleenvelope_arrow"
local SCALE_ENVELOPE_NAME_BLACK_SMOKE = "blythe_beam_swap_segment_particle_scaleenvelope_black_smoke"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_YELLOW, {
        { 0,  IntColour(255, 240, 0, 0) },
        { .2, IntColour(255, 253, 0, 200) },
        { .3, IntColour(200, 255, 0, 110) },
        { .6, IntColour(230, 245, 0, 180) },
        { .9, IntColour(255, 240, 0, 100) },
        { 1,  IntColour(255, 240, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_BLUE, {
        { 0,  IntColour(96, 249, 255, 0) },
        { .2, IntColour(96, 249, 255, 240) },
        { .3, IntColour(96, 249, 255, 180) },
        { .6, IntColour(96, 249, 255, 150) },
        { .9, IntColour(96, 249, 255, 110) },
        { 1,  IntColour(96, 249, 255, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,  IntColour(150, 150, 19, 255) },
        { .2, IntColour(255, 220, 19, 255) },
        { .8, IntColour(230, 200, 19, 255) },
        { 1,  IntColour(150, 150, 19, 255) },
    })

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_BLACK_SMOKE,
        {
            { 0,   IntColour(10, 10, 10, 0) },
            { 0.1, IntColour(10, 10, 10, 10) },
            { .3,  IntColour(10, 10, 10, 175) },
            { .52, IntColour(10, 10, 10, 90) },
            { 1,   IntColour(10, 10, 10, 0) },
        }
    )

    local scale_factor = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_THIN,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )

    scale_factor = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )

    scale_factor = 0.75
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN,
        {
            { 0,   { scale_factor * 0.12, scale_factor } },
            { 0.2, { scale_factor * 0.12, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )

    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { arrow_max_scale * 0.2, arrow_max_scale } },
            { 1, { arrow_max_scale * .001, arrow_max_scale * .001 } },
        }
    )


    local black_smoke_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_BLACK_SMOKE,
        {
            { 0, { black_smoke_max_scale * .5, black_smoke_max_scale * .5 } },
            { 1, { black_smoke_max_scale, black_smoke_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.6
local MAX_LIFETIME_ARROW = 1.0
local MAX_LIFETIME_BLACK_SMOKE = 2.0

local function emit_line_thin(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_line(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_arrow(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME_ARROW * (.6 + UnitRand() * .4))

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        2,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_black_smoke(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME_BLACK_SMOKE * (.6 + UnitRand() * .4))

    -- local uv_offset = math.random(0, 3) * .25

    -- effect:AddParticleUV(
    --     2,
    --     lifetime,    -- lifetime
    --     px, py, pz,  -- position
    --     vx, vy, vz,  -- velocity
    --     uv_offset, 0 -- uv offset
    -- )


    effect:AddRotatingParticle(
        2,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end



local function line_fn()
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
    effect:InitEmitters(3)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 2)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:EnableDepthTest(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, 0.3)


    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 2)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_BLUE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    -- effect:EnableDepthTest(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, 0.3)


    effect:SetRenderResources(2, ARROW_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(2, true)
    effect:SetMaxNumParticles(2, 8)
    effect:SetUVFrameSize(2, .25, 1)
    effect:SetMaxLifetime(2, MAX_LIFETIME_ARROW)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(2, BLENDMODE.Additive)
    effect:EnableBloomPass(2, true)
    effect:SetSortOffset(2, 2)
    effect:SetDragCoefficient(2, 0.1)

    -----------------------------------------------------
    local line_sphere_emitter = CreateSphereEmitter(0.1)
    local arrow_sphere_emitter = CreateSphereEmitter(0.2)


    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not parent then
            return
        end

        local time_alive = inst:GetTimeAlive()

        if time_alive > FRAMES and time_alive < 3 * FRAMES then
            local forward = StarIliadBasic.GetFaceVector(parent)
            local velocity = forward * 0.3
            emit_line_thin(effect, Vector3(line_sphere_emitter()), velocity)

            for i = 1, 2 do
                emit_line(effect, Vector3(line_sphere_emitter()), velocity)
            end
            for i = 1, 4 do
                -- emit_arrow(effect, Vector3(arrow_sphere_emitter()) + velocity * GetRandomMinMax(-2, 2), velocity)
                emit_arrow(effect, Vector3(arrow_sphere_emitter()), velocity)
            end
        end
    end)

    return inst
end

local function explode_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 8)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 1)

    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 8)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_BLUE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOffset(1, 0)

    --SMOKE
    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, MAX_LIFETIME_BLACK_SMOKE)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_BLACK_SMOKE)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_BLACK_SMOKE)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(1, true)
    --effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOffset(2, 0)
    effect:SetRadius(2, 3) --only needed on a single emitter
    effect:SetDragCoefficient(2, .1)

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    local remain_time = FRAMES * 3
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not parent then
            return
        end

        local time_alive = inst:GetTimeAlive()

        if time_alive > FRAMES and time_alive < 3 * FRAMES then
            for i = 1, 8 do
                local velocity = Vector3(norm_sphere_emitter()) * 0.3
                -- velocity.y = math.abs(velocity.y)
                -- local pos = Vector3(line_sphere_emitter())
                local pos = velocity:GetNormalized() * 0.66
                emit_line_thin(effect, pos, velocity)
                emit_line(effect, pos, velocity)
            end

            for i = 1, 75 do
                local pos = Vector3(norm_sphere_emitter()) * 0.2
                local velocity = Vector3(0.2 * UnitRand(), 0.1 + 0.1 * UnitRand(), 0.2 * UnitRand())
                emit_black_smoke(effect, pos, velocity)
            end
            remain_time = remain_time - FRAMES
        end
    end)

    return inst
end

return Prefab("blythe_beam_swap_segment_particle", line_fn, assets),
    Prefab("blythe_beam_swap_explode_particle", explode_fn, assets)
