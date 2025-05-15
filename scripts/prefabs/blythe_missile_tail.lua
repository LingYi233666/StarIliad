local FIRE_TEXTURE = "fx/torchfire.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local ANIMSMOKE2_TEXTURE = "fx/animsmoke2.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_FIRE = "blythe_missile_tail_fire_colourenvelope"
local SCALE_ENVELOPE_NAME_FIRE = "blythe_missile_tail_fire_scaleenvelope"

local COLOUR_ENVELOPE_NAME_ARROW = "blythe_missile_tail_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "blythe_missile_tail_arrow_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SMOKE2 = "blythe_missile_tail_smoke2_colourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE2 = "blythe_missile_tail_smoke2_scaleenvelope"

local assets =
{
    Asset("IMAGE", FIRE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", ANIMSMOKE2_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
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

    local fire_max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_FIRE,
        {
            { 0, { fire_max_scale * .5, fire_max_scale } },
            { 1, { fire_max_scale * .5 * .5, fire_max_scale * .5 } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            { 0,    IntColour(255, 150, 2, 25) },
            { .075, IntColour(255, 193, 5, 200) },
            { .3,   IntColour(255, 100, 5, 255) },
            { .6,   IntColour(255, 50, 5, 255) },
            { .9,   IntColour(255, 10, 5, 230) },
            { 1,    IntColour(255, 10, 5, 0) },
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


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE2,
        {
            { 0,   IntColour(250, 150, 2, 200) },
            { .26, IntColour(8, 8, 8, 200) },
            { .8,  IntColour(8, 8, 8, 200) },
            { 1,   IntColour(8, 8, 8, 100) },
        }
    )


    local smoke_max_scale = 0.8
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE2,
        {
            -- { 0,   { smoke_max_scale * .2, smoke_max_scale * .2 } },
            -- { .40, { smoke_max_scale * .7, smoke_max_scale * .7 } },
            -- { .60, { smoke_max_scale * .8, smoke_max_scale * .8 } },
            -- { .75, { smoke_max_scale * .9, smoke_max_scale * .9 } },
            -- { 1,   { smoke_max_scale, smoke_max_scale } },

            -- { 0,   { smoke_max_scale, smoke_max_scale } },
            -- { .40, { smoke_max_scale * .7, smoke_max_scale * .7 } },
            -- { 1,   { smoke_max_scale * 0.1, smoke_max_scale * 0.1 } },

            -- { .6, { smoke_max_scale * 0.8, smoke_max_scale * 0.8 } },
            -- { 1,  { smoke_max_scale * 0.8, smoke_max_scale * 0.8 } },
            -- { 1, { smoke_max_scale, smoke_max_scale } },

            { 0, { smoke_max_scale, smoke_max_scale } },
            { 1, { smoke_max_scale, smoke_max_scale } },
        }
    )




    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local FIRE_MAX_LIFETIME = 0.3
local ARROW_MAX_LIFETIME = 0.2
local SMOKE2_MAX_LIFETIME = 0.5

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

local function emit_smoke2_fn(effect, pos, velocity)
    local lifetime = SMOKE2_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = velocity:Get()

    local angle = math.random() * 360
    local ang_vel = (UnitRand() - 1) * 0

    local u_offset = math.random(0, 3) * .25
    local v_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        1,
        lifetime,          -- lifetime
        px, py, pz,        -- position
        vx, vy, vz,        -- velocity
        angle, ang_vel,
        u_offset, v_offset -- uv offset
    )
end


local function normal_fn()
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
        local axis_y = Vector3(0, 1, 0)
        local axis_z = axis_y:Cross(forward):GetNormalized()
        -----------------------------------------------------

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


local function super_fn()
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

    effect:SetRenderResources(1, ANIMSMOKE2_TEXTURE, REVEAL_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetMaxNumParticles(1, 128)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE2)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE2)
    effect:SetMaxLifetime(1, SMOKE2_MAX_LIFETIME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetUVFrameSize(1, 0.25, 0.25)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, 0.3)

    -----------------------------------------------------
    inst.last_pos = nil

    local sphere_emitter_fire = CreateSphereEmitter(.1)
    -- local sphere_emitter_fire = StarIliadMath.CustomSphereEmitter(0, 0.1, 75 * DEGREES, 105 * DEGREES, -15 * DEGREES,
    -- 15 * DEGREES)

    local sphere_emitter_smoke2 = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local forward = StarIliadBasic.GetFaceVector(parent)
        local axis_y = Vector3(0, 1, 0)
        local axis_z = axis_y:Cross(forward):GetNormalized()
        -----------------------------------------------------

        -- local spawn_center_fire = -forward * 0.3
        -- local velocity_fire = -forward * 0.1
        -- local offset_fire = Vector3(sphere_emitter_fire())
        -- offset_fire = forward * offset_fire.x + axis_y * offset_fire.y + axis_z * offset_fire.z

        -- emit_fire_fn(effect, spawn_center_fire + offset_fire, velocity_fire)

        local spawn_center_fire = -forward * 0.2
        local velocity_fire = -forward * 0.05
        local offset_fire = Vector3(sphere_emitter_fire())

        emit_fire_fn(effect, spawn_center_fire + offset_fire, velocity_fire)


        -----------------------------------------------------
        -- if inst.last_pos == nil or (parent:GetPosition() - inst.last_pos):Length() >= 0.1 then
        --     local spawn_center_smoke2 = -forward * 0.3
        --     local velocity_smoke2 = forward * GetRandomMinMax(0.05, 0.1)
        --     local offset_smoke2 = Vector3(sphere_emitter_smoke2())

        --     emit_smoke2_fn(effect, spawn_center_smoke2 + offset_smoke2, velocity_smoke2)

        --     inst.last_pos = parent:GetPosition()
        -- end

        local spawn_center_smoke2 = -forward * 0.1
        for i = 1, 2 do
            local velocity_smoke2 = forward * GetRandomMinMax(0.05, 0.1)
            local offset_smoke2 = Vector3(sphere_emitter_smoke2())

            emit_smoke2_fn(effect, spawn_center_smoke2 + offset_smoke2, velocity_smoke2)
        end


        inst.last_pos = parent:GetPosition()
    end)

    return inst
end

return Prefab("blythe_missile_tail", normal_fn, assets),
    Prefab("blythe_super_missile_tail", super_fn, assets)
