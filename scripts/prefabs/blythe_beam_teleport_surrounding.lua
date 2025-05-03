local SPARKLE_TEXTURE = "fx/smoke.tex"
-- smoke
-- sparkle

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_BLUE = "blythe_beam_teleport_surrounding_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_GOLDEN = "blythe_beam_teleport_surrounding_golden_colourenvelope"
local SCALE_ENVELOPE_NAME = "blythe_beam_teleport_surrounding_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- local envs_golden = {}
    -- local envs_blue = {}
    -- local t = 0
    -- local step = .15

    -- while t + step + .01 < 1 do
    --     table.insert(envs_golden, { t, IntColour(255, 255, 150, 255) })
    --     table.insert(envs_blue, { t, IntColour(0, 229, 232, 255) })

    --     t = t + step

    --     table.insert(envs_golden, { t, IntColour(255, 255, 150, 0) })
    --     table.insert(envs_blue, { t, IntColour(0, 229, 232, 0) })

    --     t = t + .01
    -- end
    -- table.insert(envs_golden, { 1, IntColour(255, 255, 150, 0) })
    -- table.insert(envs_blue, { 1, IntColour(0, 229, 232, 0) })

    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_GOLDEN, envs_golden)
    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_BLUE, envs_blue)

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_GOLDEN, {
        -- { 0,   IntColour(255, 255, 150, 0) },
        { 0, IntColour(255, 255, 150, 255) },
        { 1, IntColour(255, 255, 150, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_BLUE, {
        -- { 0,   IntColour(0, 229, 232, 0) },
        { 0, IntColour(0, 229, 232, 255) },
        { 1, IntColour(0, 229, 232, 0) },
    })

    local sparkle_max_scale = 0.4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
            -- { 1, { sparkle_max_scale * .1, sparkle_max_scale * .1 } },
            -- { 1, { sparkle_max_scale, sparkle_max_scale } },

        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.2

local function emit_sparkle_fn(index, effect, pos, vel)
    local vx, vy, vz = vel:Get()
    local lifetime = MAX_LIFETIME
    local px, py, pz = pos:Get()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    -- local uv_offset = 3 * .25

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()


    inst._stop_event = net_event(inst.GUID, "inst._stop_event")

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 1024)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_BLUE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    -- effect:SetDragCoefficient(0, 0.005)
    -- effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)

    effect:SetRenderResources(1, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetUVFrameSize(1, .25, 1)
    effect:SetMaxNumParticles(1, 1024)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_GOLDEN)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    -- effect:SetDragCoefficient(1, 0.005)
    -- effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 2)
    effect:SetFollowEmitter(1, true)

    -----------------------------------------------------


    inst.last_emit_time = GetTime()
    inst.angle = math.random(360)
    inst.can_emit = true



    local radius = 0.25
    local speed = -0.33
    local angle_speed = 45
    local num_step = 10
    local center_f = 0.5


    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not parent then
            return
        end

        if not inst.can_emit then
            return
        end

        if inst.last_emit_time == nil or GetTime() - inst.last_emit_time >= 1 * FRAMES then
            local forward = StarIliadBasic.GetFaceVector(parent)
            local axis_y = Vector3(0, 1, 0)
            local axis_x = forward:Cross(axis_y):GetNormalized()
            local center = forward * center_f
            local velocity = forward * speed

            local velocity2 = forward * -34

            local last_angle = inst.angle
            local next_angle = inst.angle + angle_speed

            local angle_delta = (next_angle - last_angle) / num_step

            for i = 0, num_step - 1 do
                local cur_angle = last_angle + angle_delta * i
                -- local cur_time = 100 * duration_emit * i / num_step
                local cur_time = (1 - i / num_step)

                local x_value = math.cos(cur_angle * DEGREES) * radius
                local y_value = math.sin(cur_angle * DEGREES) * radius

                local pos1 = center + axis_x * x_value + axis_y * y_value + velocity * cur_time
                local pos2 = center - axis_x * x_value - axis_y * y_value + velocity * cur_time

                emit_sparkle_fn(0, effect, pos1, velocity)
                emit_sparkle_fn(1, effect, pos2, velocity)
            end



            inst.angle = next_angle
            inst.last_emit_time = GetTime()
        end
    end)


    inst:ListenForEvent("inst._stop_event", function()
        -- print("Stop event trigger!")
        inst.VFXEffect:SetDragCoefficient(0, 9999999)
        inst.VFXEffect:SetDragCoefficient(1, 9999999)

        inst.can_emit = false
    end)



    return inst
end

return Prefab("blythe_beam_teleport_surrounding", fn, assets)
