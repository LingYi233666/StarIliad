local CIRCLE_TEXTURE = "fx/sparkle.tex"
local STAR_TEXTURE = resolvefilepath("fx/stariliad_falling_star.tex")
local TAIL_TEXTURE = "fx/spark.tex"
-- local TAIL_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_CIRCLE_BLUE = "stariliad_falling_star_colourenvelope_circle_blue"
local COLOUR_ENVELOPE_NAME_CIRCLE_PINK = "stariliad_falling_star_colourenvelope_circle_pink"
local COLOUR_ENVELOPE_NAME_CIRCLE_PURPLE = "stariliad_falling_star_colourenvelope_circle_purple"
local COLOUR_ENVELOPE_NAME_CIRCLE_YELLOW = "stariliad_falling_star_colourenvelope_circle_yellow"
local SCALE_ENVELOPE_NAME_CIRCLE = "stariliad_falling_star_scaleenvelope_circle"

local COLOUR_ENVELOPE_NAME_STAR_BLUE = "stariliad_falling_star_colourenvelope_star_blue"
local COLOUR_ENVELOPE_NAME_STAR_YELLOW = "stariliad_falling_star_colourenvelope_star_yellow"
local SCALE_ENVELOPE_NAME_STAR = "stariliad_falling_star_scaleenvelope_star"

local COLOUR_ENVELOPE_NAME_TAIL = "stariliad_falling_star_colourenvelope_tail"
local SCALE_ENVELOPE_NAME_TAIL = "stariliad_falling_star_scaleenvelope_tail"

local SCALE_ENVELOPE_NAME_CIRCLE2 = "stariliad_falling_star_scaleenvelope_circle2"

local SCALE_ENVELOPE_NAME_TAIL2 = "stariliad_falling_star_scaleenvelope_tail2"


local assets =
{
    Asset("IMAGE", CIRCLE_TEXTURE),
    Asset("IMAGE", STAR_TEXTURE),
    Asset("IMAGE", TAIL_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function CreateShiningColour(r, g, b, a, step)
    a = a or 255
    step = step or 0.15
    -- step = step or 0.3
    local t = 0

    local envs = {}
    while t + step + 0.01 < 1 do
        table.insert(envs, { t, IntColour(r, g, b, a) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 255, 255, 255) })
        t = t + .01
    end

    table.insert(envs, { 1, IntColour(r, g, b, 0) })

    return envs
end

local function CreateFadingColour(r, g, b, a)
    a = a or 255
    return {
        { 0, IntColour(r, g, b, a) },
        { 1, IntColour(r, g, b, 0) },
    }
end

local function CreateConstantColour(r, g, b, a)
    a = a or 255
    return {
        { 0, IntColour(r, g, b, a) },
        { 1, IntColour(r, g, b, a) },
    }
end

local function InitEnvelope()
    -- local envs = {}
    -- local t = 0
    -- local step = .15
    -- while t + step + .01 < 1 do
    --     table.insert(envs, { t, IntColour(255, 255, 150, 255) })
    --     t = t + step
    --     table.insert(envs, { t, IntColour(255, 255, 150, 0) })
    --     t = t + .01
    -- end
    -- table.insert(envs, { 1, IntColour(255, 255, 150, 0) })

    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_BLUE, CreateShiningColour(0, 229, 232))
    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_BLUE, CreateShiningColour(0, 0, 232))
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_BLUE, CreateShiningColour(0, 255, 255))

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_PINK, CreateShiningColour(240, 92, 240))

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_PURPLE, CreateShiningColour(230, 0, 230))

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_CIRCLE_YELLOW, CreateShiningColour(230, 230, 0))


    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_STAR_YELLOW, CreateConstantColour(230, 230, 0))

    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_STAR_BLUE, CreateConstantColour(0, 229, 232))
    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_STAR_BLUE, CreateConstantColour(0, 255, 255))
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_STAR_BLUE, CreateConstantColour(0, 120, 190))

    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_TAIL, CreateConstantColour(0, 10, 232))
    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_TAIL, CreateConstantColour(230, 230, 0))
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_TAIL, CreateFadingColour(0, 10, 232))



    -- local circle_max_scale = 0.6
    local circle_max_scale = 0.4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_CIRCLE,
        {
            -- { 0,   { circle_max_scale * .4, circle_max_scale * .4 } },
            -- { .50, { circle_max_scale * .6, circle_max_scale * .6 } },
            -- { .65, { circle_max_scale, circle_max_scale } },
            -- { 1,   { circle_max_scale * 0.01, circle_max_scale * 0.01 } },

            { 0,   { circle_max_scale, circle_max_scale } },
            { 0.9, { circle_max_scale, circle_max_scale } },
            { 1,   { circle_max_scale * 0.1, circle_max_scale * 0.1 } },
        }
    )


    local star_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_STAR,
        {
            { 0, { star_max_scale, star_max_scale } },
            { 1, { star_max_scale * 0.01, star_max_scale * 0.01 } },
        }
    )

    -- local tail_max_scale = 3
    local tail_max_scale = 15
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_TAIL,
        {
            { 0, { tail_max_scale, tail_max_scale } },
            -- { 1, { tail_max_scale * 0.01, tail_max_scale * 0.5 } },
            { 1, { tail_max_scale, tail_max_scale * 0.9 } },

        }
    )



    circle_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_CIRCLE2,
        {
            { 0,   { circle_max_scale, circle_max_scale } },
            { 0.9, { circle_max_scale, circle_max_scale } },
            { 1,   { circle_max_scale * 0.1, circle_max_scale * 0.1 } },
        }
    )

    tail_max_scale = 2.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_TAIL2,
        {
            -- { 0,   { tail_max_scale, tail_max_scale } },
            -- { 0.2, { tail_max_scale * 0.1, tail_max_scale * 0.1 } },
            -- { 1,   { tail_max_scale * 0.1, tail_max_scale * 0.1 } },


            -- { 0, { tail_max_scale, tail_max_scale } },
            -- { 1, { tail_max_scale * 0.1, tail_max_scale * 0.1 } },


            { 0,   { tail_max_scale, tail_max_scale } },
            { 0.2, { tail_max_scale * 0.5, tail_max_scale * 0.5 } },
            { 1,   { tail_max_scale * 0.5, tail_max_scale * 0.5 } },


        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_CIRCLE = 3
local MAX_LIFETIME_STAR = 1.75
local MAX_LIFETIME_TAIL = 0.66

local MAX_LIFETIME_CIRCLE2 = 2
local MAX_LIFETIME_TAIL2 = 3

local function emit_circle_fn(effect, index, pos, velocity)
    local lifetime = MAX_LIFETIME_CIRCLE * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        index,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        uv_offset, 0    -- uv offset
    )
end

local function emit_star_fn(effect, index, pos, velocity)
    local lifetime = MAX_LIFETIME_STAR * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    -- local angle = math.random() * 360
    -- local ang_vel = (UnitRand() - 1) * 5

    local angle = math.random(-5, 5)
    local ang_vel = (UnitRand() - 1) * 0.5

    effect:AddRotatingParticle(
        index,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
    )
end

local function emit_tail_fn(effect, pos, velocity)
    local lifetime = MAX_LIFETIME_TAIL * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    -- effect:AddParticle(
    --     6,
    --     lifetime,   -- lifetime
    --     px, py, pz, -- position
    --     vx, vy, vz  -- velocity
    -- )

    effect:AddParticleUV(
        6,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz, -- velocity
        0.75, 0     -- uv offset
    )
end

local function emit_tail2_fn(effect, index, pos, velocity)
    local lifetime = MAX_LIFETIME_TAIL2 * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    effect:AddParticleUV(
        index,
        lifetime,                   -- lifetime
        px, py, pz,                 -- position
        vx, vy, vz,                 -- velocity
        math.random(0, 3) * 0.25, 0 -- uv offset
    )
end

local function emit_circle2_fn(effect, index, pos, velocity)
    local lifetime = MAX_LIFETIME_CIRCLE2 * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 1

    effect:AddRotatingParticleUV(
        index,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        uv_offset, 0    -- uv offset
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
    effect:InitEmitters(7)


    local colour_names_circle = {
        COLOUR_ENVELOPE_NAME_CIRCLE_BLUE,
        COLOUR_ENVELOPE_NAME_CIRCLE_PINK,
        COLOUR_ENVELOPE_NAME_CIRCLE_PURPLE,
        COLOUR_ENVELOPE_NAME_CIRCLE_YELLOW,
    }

    -- index: 0~3
    for k, v in pairs(colour_names_circle) do
        local index = k - 1
        effect:SetRenderResources(index, CIRCLE_TEXTURE, ADD_SHADER)
        effect:SetRotationStatus(index, true)
        effect:SetUVFrameSize(index, .25, 1)
        effect:SetMaxNumParticles(index, 64)
        effect:SetMaxLifetime(index, MAX_LIFETIME_CIRCLE)
        effect:SetColourEnvelope(index, v)
        effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_CIRCLE)
        effect:SetBlendMode(index, BLENDMODE.Additive)
        effect:EnableBloomPass(index, true)
        effect:SetSortOrder(index, 1)
        -- effect:SetSortOffset(index, 2)
    end

    local colour_names_star = {
        COLOUR_ENVELOPE_NAME_STAR_BLUE,
        COLOUR_ENVELOPE_NAME_STAR_YELLOW,
    }

    -- index: 4~5
    for k, v in pairs(colour_names_star) do
        local index = k + 3
        effect:SetRenderResources(index, STAR_TEXTURE, ADD_SHADER)
        effect:SetRotationStatus(index, true)
        effect:SetMaxNumParticles(index, 32)
        effect:SetMaxLifetime(index, MAX_LIFETIME_STAR)
        effect:SetColourEnvelope(index, v)
        effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_STAR)
        effect:SetBlendMode(index, BLENDMODE.Additive)
        effect:EnableBloomPass(index, true)
        effect:SetSortOrder(index, 1)
        -- effect:SetSortOffset(index, 2)
    end

    effect:SetRenderResources(6, TAIL_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(6, true)
    effect:SetUVFrameSize(6, .25, 1)
    effect:SetMaxNumParticles(6, 128)
    effect:SetMaxLifetime(6, MAX_LIFETIME_TAIL)
    effect:SetColourEnvelope(6, COLOUR_ENVELOPE_NAME_TAIL)
    effect:SetScaleEnvelope(6, SCALE_ENVELOPE_NAME_TAIL)
    effect:SetBlendMode(6, BLENDMODE.Additive)
    effect:EnableBloomPass(6, true)
    effect:SetDragCoefficient(6, 0.2)
    effect:SetFollowEmitter(6, true)
    -- effect:SetSortOffset(6, -1)

    -----------------------------------------------------

    local circle_addition = 20 / 30
    local star_addition = 3 / 30
    local tail_addition = 3 / 30

    local sphere_emitter_circle = CreateSphereEmitter(0.3)
    local sphere_emitter_star = CreateSphereEmitter(0.2)
    local sphere_emitter_tail = CreateSphereEmitter(0.05)


    inst.circle_to_emit = 0
    inst.star_to_emit = 0
    inst.tail_to_emit = 0
    inst.last_pos = nil
    inst.velocity = nil

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        inst.circle_to_emit = inst.circle_to_emit + circle_addition
        inst.star_to_emit = inst.star_to_emit + star_addition

        while inst.circle_to_emit > 0 do
            local pos = Vector3(sphere_emitter_circle())
            local vel = pos:GetNormalized() * GetRandomMinMax(0.01, 0.02)
            emit_circle_fn(effect, math.random(0, 3), pos, vel)
            inst.circle_to_emit = inst.circle_to_emit - 1
        end

        while inst.star_to_emit > 0 do
            local pos = Vector3(sphere_emitter_star())
            local vel = pos:GetNormalized() * GetRandomMinMax(0.005, 0.01)
            emit_star_fn(effect, math.random(4, 5), pos, vel)
            inst.star_to_emit = inst.star_to_emit - 1
        end

        -- local cur_pos = parent:GetPosition()
        -- if inst.last_pos then
        --     local velocity = (cur_pos - inst.last_pos)
        --     if velocity:Length() > 1e-6 then
        --         velocity = velocity:GetNormalized()

        --         effect:ClearAllParticles(6)
        --         local pos = -velocity * 2
        --         emit_tail_fn(effect, pos, velocity * 0.01)
        --     end
        -- end
        -- inst.last_pos = cur_pos

        if not inst.velocity then
            local cur_pos = parent:GetPosition()
            if inst.last_pos then
                local velocity = (cur_pos - inst.last_pos)
                if velocity:Length() > 1e-6 then
                    inst.velocity = velocity:GetNormalized()
                end
            end
            inst.last_pos = cur_pos
        else
            inst.tail_to_emit = inst.tail_to_emit + tail_addition

            while inst.tail_to_emit > 0 do
                local pos = -inst.velocity * 2
                emit_tail_fn(effect, pos, inst.velocity * 0.01)

                inst.tail_to_emit = inst.tail_to_emit - 1
            end
        end
    end)

    return inst
end


local function hit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    if TheWorld.ismastersim then
        inst:DoTaskInTime(1, inst.Remove)
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(6)

    -- local colour_names_tail2 = {
    --     COLOUR_ENVELOPE_NAME_CIRCLE_BLUE,
    --     COLOUR_ENVELOPE_NAME_CIRCLE_YELLOW,
    -- }

    -- for k, v in pairs(colour_names_tail2) do
    --     local index = k - 1
    --     effect:SetRenderResources(index, TAIL_TEXTURE, ADD_SHADER)
    --     effect:SetRotateOnVelocity(index, true)
    --     effect:SetUVFrameSize(index, .25, 1)
    --     effect:SetMaxNumParticles(index, 32)
    --     effect:SetMaxLifetime(index, MAX_LIFETIME_TAIL2)
    --     effect:SetColourEnvelope(index, v)
    --     effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_TAIL2)
    --     effect:SetBlendMode(index, BLENDMODE.Additive)
    --     effect:EnableBloomPass(index, true)
    --     effect:SetDragCoefficient(index, 0.2)
    -- end

    local colour_names_circle = {
        COLOUR_ENVELOPE_NAME_CIRCLE_BLUE,
        COLOUR_ENVELOPE_NAME_CIRCLE_PINK,
        COLOUR_ENVELOPE_NAME_CIRCLE_PURPLE,
        COLOUR_ENVELOPE_NAME_CIRCLE_YELLOW,
    }

    -- index: 0~3
    for k, v in pairs(colour_names_circle) do
        local index = k - 1
        effect:SetRenderResources(index, CIRCLE_TEXTURE, ADD_SHADER)
        effect:SetRotationStatus(index, true)
        effect:SetUVFrameSize(index, .25, 1)
        effect:SetMaxNumParticles(index, 64)
        effect:SetMaxLifetime(index, MAX_LIFETIME_CIRCLE2)
        effect:SetColourEnvelope(index, v)
        effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_CIRCLE2)
        effect:SetBlendMode(index, BLENDMODE.Additive)
        effect:EnableBloomPass(index, true)
        effect:SetDragCoefficient(index, 0.2)
    end

    local colour_names_star = {
        COLOUR_ENVELOPE_NAME_STAR_BLUE,
        COLOUR_ENVELOPE_NAME_STAR_YELLOW,
    }

    for k, v in pairs(colour_names_star) do
        local index = k + 3
        effect:SetRenderResources(index, STAR_TEXTURE, ADD_SHADER)
        effect:SetRotationStatus(index, true)
        effect:SetMaxNumParticles(index, 32)
        effect:SetMaxLifetime(index, MAX_LIFETIME_STAR)
        effect:SetColourEnvelope(index, v)
        effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_STAR)
        effect:SetBlendMode(index, BLENDMODE.Additive)
        effect:EnableBloomPass(index, true)
        effect:SetDragCoefficient(index, 0.2)
    end

    -----------------------------------------------------

    local sphere_emitter_tail = CreateSphereEmitter(0.05)
    local sphere_emitter_star = CreateSphereEmitter(0.05)

    inst.emitted = false

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        if inst:GetTimeAlive() < 2 * FRAMES then
            return
        end

        if inst.emitted then
            return
        end

        for i = 1, math.random(10, 15) do
            local pos = Vector3(sphere_emitter_tail())
            local vel = pos:GetNormalized() * GetRandomMinMax(0.3, 0.4)

            -- emit_tail2_fn(effect, math.random(0, 3), pos, vel)
            emit_circle2_fn(effect, math.random(0, 3), pos, vel)
        end

        for i = 1, math.random(5, 6) do
            local pos = Vector3(sphere_emitter_star())
            pos.y = math.abs(pos.y)
            local vel = pos:GetNormalized() * GetRandomMinMax(0.2, 0.3)

            -- emit_star_fn(effect, math.random(2, 3), pos, vel)
            emit_star_fn(effect, math.random(4, 5), pos, vel)
        end

        inst.emitted = true
    end)

    return inst
end

return Prefab("stariliad_falling_star_fx", fn, assets),
    Prefab("stariliad_falling_star_hit_fx", hit_fn, assets)
