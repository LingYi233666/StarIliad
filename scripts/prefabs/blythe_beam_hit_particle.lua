local POINT_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local SPARKLE_TEXTURE = "fx/sparkle.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_SCALE_ENVELOPE_NAME = "blythe_beam_hit_particle_point_scaleenvelope"
local SPARKLE_SCALE_ENVELOPE_NAME = "blythe_beam_hit_particle_sparkle_scaleenvelope"

local ARROW_SCALE_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_scaleenvelope"

local SMOKE_SCALE_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_scaleenvelope"

local POINT_COLOUR_ENVELOPE_NAME = "blythe_beam_hit_particle_point_colourenvelope"
local ARROW_COLOUR_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_colourenvelope"
local SMOKE_COLOUR_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_colourenvelope"

local POINT_COLOUR_BLUE_ENVELOPE_NAME = "blythe_beam_hit_particle_point_blue_colourenvelope"
local ARROW_COLOUR_BLUE_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_blue_colourenvelope"
local SMOKE_COLOUR_BLUE_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_blue_colourenvelope"

local POINT_COLOUR_PURPLE_ENVELOPE_NAME = "blythe_beam_hit_particle_point_purple_colourenvelope"
local ARROW_COLOUR_PURPLE_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_purple_colourenvelope"
local SMOKE_COLOUR_PURPLE_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_purple_colourenvelope"

local POINT_COLOUR_GREEN_ENVELOPE_NAME = "blythe_beam_hit_particle_point_green_colourenvelope"
local ARROW_COLOUR_GREEN_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_green_colourenvelope"
local SMOKE_COLOUR_GREEN_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_green_colourenvelope"

local POINT_COLOUR_RED_ENVELOPE_NAME = "blythe_beam_hit_particle_point_red_colourenvelope"
local ARROW_COLOUR_RED_ENVELOPE_NAME = "blythe_beam_hit_particle_arrow_red_colourenvelope"
-- local SMOKE_COLOUR_RED_ENVELOPE_NAME = "blythe_beam_hit_particle_smoke_red_colourenvelope"


local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", SPARKLE_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(232, 160, 0, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(232, 160, 0, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_ENVELOPE_NAME, envs)


    -- Blue
    envs = {}
    t = 0
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(0, 100, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 100, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 100, 232, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_BLUE_ENVELOPE_NAME, envs)

    -- Purple
    envs = {}
    t = 0
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(255, 0, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 229, 232, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_PURPLE_ENVELOPE_NAME, envs)

    -- Green
    envs = {}
    t = 0
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(5, 0, 10, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(5, 229, 10, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(5, 229, 10, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_GREEN_ENVELOPE_NAME, envs)

    -- Red
    envs = {}
    t = 0
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(220, 10, 0, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(220, 229, 229, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(220, 10, 0, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_RED_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 0.33
    EnvelopeManager:AddVector2Envelope(
        POINT_SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    sparkle_max_scale = 0.66
    EnvelopeManager:AddVector2Envelope(
        SPARKLE_SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,  IntColour(255, 90, 70, 180) },
            { .2, IntColour(255, 120, 90, 255) },
            { .8, IntColour(255, 90, 70, 175) },
            { 1,  IntColour(0, 0, 0, 0) },
        }
    )

    -- Blue
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_BLUE_ENVELOPE_NAME,
        {
            { 0,  IntColour(0, 240, 240, 180) },
            { .2, IntColour(10, 240, 240, 255) },
            { .6, IntColour(10, 240, 240, 175) },
            { 1,  IntColour(0, 240, 240, 0) },
        }
    )

    -- Purple
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_PURPLE_ENVELOPE_NAME,
        {
            { 0,  IntColour(240, 70, 240, 180) },
            { .2, IntColour(240, 100, 240, 255) },
            { .6, IntColour(240, 100, 240, 175) },
            { 1,  IntColour(240, 70, 240, 0) },
        }
    )

    -- Green
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_GREEN_ENVELOPE_NAME,
        {
            { 0,  IntColour(5, 200, 10, 180) },
            { .2, IntColour(5, 240, 20, 255) },
            { .6, IntColour(5, 240, 20, 175) },
            { 1,  IntColour(5, 200, 10, 0) },
        }
    )

    -- Red
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_RED_ENVELOPE_NAME,
        {
            { 0,  IntColour(200, 10, 5, 180) },
            { .2, IntColour(240, 20, 5, 255) },
            { .6, IntColour(240, 20, 5, 175) },
            { 1,  IntColour(200, 10, 5, 0) },
        }
    )

    local arrow_max_scale_width = 7
    local arrow_max_scale_height = 6
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {

            { 0,   { arrow_max_scale_width * 0.1, arrow_max_scale_height * 0.5 } },
            { 0.2, { arrow_max_scale_width * 0.2, arrow_max_scale_height } },
            { 1,   { arrow_max_scale_width * 0.002, arrow_max_scale_height * 0.000001 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,   IntColour(255, 90, 70, 180) },
            { 0.1, IntColour(255, 120, 90, 255) },
            { 0.2, IntColour(0, 0, 0, 200) },
            { 0.6, IntColour(0, 0, 0, 100) },
            { 1,   IntColour(0, 0, 0, 0) },
        }
    )

    -- Blue
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_BLUE_ENVELOPE_NAME,
        {
            { 0,   IntColour(255, 247, 255, 0) },
            { 0.1, IntColour(255, 239, 255, 90) },
            { .3,  IntColour(255, 239, 255, 150) },
            { .52, IntColour(255, 239, 255, 90) },
            { 1,   IntColour(255, 239, 255, 0) },
        }
    )

    -- Purple
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_PURPLE_ENVELOPE_NAME,
        {
            { 0,   IntColour(120, 50, 120, 0) },
            { 0.1, IntColour(120, 50, 120, 90) },
            { .3,  IntColour(120, 50, 120, 150) },
            { .52, IntColour(120, 50, 120, 90) },
            { 1,   IntColour(120, 50, 120, 0) },
        }
    )

    -- Green
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_GREEN_ENVELOPE_NAME,
        {
            { 0,   IntColour(5, 200, 20, 0) },
            { 0.1, IntColour(5, 220, 20, 90) },
            { .3,  IntColour(5, 240, 20, 150) },
            { .52, IntColour(5, 220, 20, 90) },
            { 1,   IntColour(5, 200, 20, 0) },
        }
    )


    local circle_max_scale = 0.22
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0, { circle_max_scale, circle_max_scale } },
            { 1, { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.3
local ARROW_MAX_LIFETIME = 0.22
local SMOKE_MAX_LIFETIME = 0.9

local function emit_point_fn(effect, sphere_emitter)
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .2 * UnitRand(), 0, .2 * UnitRand()

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


local function emit_arrow_fn(effect, sphere_emitter, double_emit)
    local lifetime = ARROW_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, 0, pz):GetNormalized() * 0.33):Get()

    local uv_offset = math.random(2, 3) * .25

    effect:AddParticleUV(
        1,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )

    if double_emit then
        effect:AddParticleUV(
            1,
            lifetime,      -- lifetime
            -px, -py, -pz, -- position
            -vx, -vy, -vz, -- velocity
            uv_offset, 0   -- uv offset
        )
    end
end

local function emit_smoke_fn(effect, sphere_emitter)
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .2 * UnitRand(), 0, .2 * UnitRand()


    effect:AddRotatingParticle(
        2,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 0.1     -- angle velocity
    )
end


local function common_fn(num_factor_point, num_factor_arrow, num_factor_smoke)
    num_factor_point = num_factor_point or 1
    num_factor_arrow = num_factor_arrow or 1
    num_factor_smoke = num_factor_smoke or 1

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

    --SPARKLE
    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 2)
    -- effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .08)

    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 25)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    -- effect:SetSortOrder(1, 1)
    -- effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, .001)
    effect:SetRotateOnVelocity(1, true)
    -- effect:SetAcceleration(1, 0, -0.15, 0)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    -- effect:SetSortOrder(2, 0)
    -- effect:SetSortOffset(2, 0)
    effect:SetDragCoefficient(2, .16)

    local sphere_emitter = CreateSphereEmitter(0.01)

    inst.should_emit = false
    inst:DoTaskInTime(FRAMES, function()
        inst.should_emit = true
    end)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if inst.should_emit and parent ~= nil then
            for i = 1, math.random(8, 12) * num_factor_point do
                emit_point_fn(effect, sphere_emitter)
            end

            for i = 1, math.random(2, 3) * num_factor_arrow do
                emit_arrow_fn(effect, sphere_emitter, true)
            end

            for i = 1, math.random(3, 4) * num_factor_smoke do
                emit_smoke_fn(effect, sphere_emitter)
            end

            inst.should_emit = false
        end
    end)


    return inst
end

local function fn()
    local inst = common_fn()

    return inst
end

local function blue_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    -- inst.VFXEffect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    -- inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
    -- inst.VFXEffect:SetScaleEnvelope(0, SPARKLE_SCALE_ENVELOPE_NAME)

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_BLUE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_BLUE_ENVELOPE_NAME)

    return inst
end

local function purple_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetBlendMode(2, BLENDMODE.AlphaAdditive)

    return inst
end


local function green_fn()
    local inst = common_fn(nil, nil, 0.6)

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_GREEN_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_GREEN_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_GREEN_ENVELOPE_NAME)
    -- inst.VFXEffect:SetBlendMode(2, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied

    return inst
end

local function red_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_RED_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_RED_ENVELOPE_NAME)
    -- inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_RED_ENVELOPE_NAME)
    -- inst.VFXEffect:SetBlendMode(2, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied

    return inst
end

local function purple_half_fn()
    local inst = common_fn(0.5, 0.75, 0.5)

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_PURPLE_ENVELOPE_NAME)
    inst.VFXEffect:SetBlendMode(2, BLENDMODE.AlphaAdditive)

    return inst
end


local function green_half_fn()
    local inst = common_fn(0.5, 0.5, 0.5)

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_GREEN_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_GREEN_ENVELOPE_NAME)
    inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_GREEN_ENVELOPE_NAME)
    -- inst.VFXEffect:SetBlendMode(2, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied

    return inst
end


return Prefab("blythe_beam_hit_particle", fn, assets),
    Prefab("blythe_beam_hit_particle_blue", blue_fn, assets),
    Prefab("blythe_beam_hit_particle_purple", purple_fn, assets),
    Prefab("blythe_beam_hit_particle_green", green_fn, assets),
    Prefab("blythe_beam_hit_particle_red", red_fn, assets),
    Prefab("blythe_beam_hit_particle_purple_half", purple_half_fn, assets),
    Prefab("blythe_beam_hit_particle_green_half", green_half_fn, assets)
