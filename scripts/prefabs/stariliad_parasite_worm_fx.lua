-- local WORM_TEXTURE = resolvefilepath("fx/stariliad_worm.tex")
local WORM_TEXTURE = resolvefilepath("fx/stariliad_worm2.tex")


local ADD_SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "stariliad_parasite_worm_colourenvelope"
local SCALE_ENVELOPE_NAME = "stariliad_parasite_worm_scaleenvelope"

local assets =
{
    Asset("IMAGE", WORM_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        -- { 0,   IntColour(100, 100, 100, 255) },
        -- { 0.4, IntColour(255, 255, 255, 255) },
        -- { 0.7, IntColour(255, 255, 255, 255) },
        -- { 1,   IntColour(90, 90, 90, 255) },

        { 0,   IntColour(100, 100, 100, 255) },
        { 0.2, IntColour(255, 255, 255, 255) },
        { 0.4, IntColour(255, 255, 255, 255) },
        { 0.5, IntColour(90, 90, 90, 255) },
        { 1,   IntColour(90, 90, 90, 0) },
    })

    local sparkle_max_scale = 2.0
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,   { sparkle_max_scale * 0.5, sparkle_max_scale * 0.5 } },
            { 0.1, { sparkle_max_scale, sparkle_max_scale } },
            { 1,   { sparkle_max_scale * 0.8, sparkle_max_scale * 0.8 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 5

local function emit_worm_fn(effect, vel, sphere_emitter)
    local lifetime = MAX_LIFETIME * (.6 + UnitRand() * .4)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local u_offset = math.random(0, 1) * .5
    local v_offset = math.random(0, 1) * .5
    local ang_vel = (UnitRand() - 1) * 15

    effect:AddRotatingParticleUV(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vel.x, vel.y, vel.z, -- velocity
        angle, ang_vel,      -- angle, angular_velocity
        u_offset, v_offset   -- uv offset
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
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, WORM_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 0.5, 0.5)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetAcceleration(0, 0, -0.8, 0)
    effect:SetGroundPhysics(0, true)
    -- effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    inst.sphere_emitter = CreateSphereEmitter(.25)
    inst.emit_addition = 3
    inst.rotation_variance = 30
    inst.vel_fn = nil

    local rotate_axis_emitter = CreateSphereEmitter(1)
    local num_to_emit = 0

    EmitterManager:AddEmitter(inst, nil, function()
        if not inst.vel_fn then
            return
        end

        num_to_emit = num_to_emit + inst.emit_addition
        while num_to_emit > 1 do
            local vel = inst:vel_fn()
            if not vel then
                return
            end

            local rotate_axis = Vector3(rotate_axis_emitter()):GetNormalized()
            local vel2 = StarIliadMath.RotateVector3(vel, rotate_axis, math.random() * inst.rotation_variance)

            emit_worm_fn(effect, vel2, inst.sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

-- Deprecated
-- local function fn()
--     local inst = common_fn()

--     inst._vx = net_float(inst.GUID, "inst._vx")
--     inst._vy = net_float(inst.GUID, "inst._vy")
--     inst._vz = net_float(inst.GUID, "inst._vz")

--     --Dedicated server does not need to spawn local particle fx
--     if TheNet:IsDedicated() then
--         return inst
--     end

--     local effect = inst.VFXEffect

--     local sphere_emitter = CreateSphereEmitter(.25)
--     local rotate_axis_emitter = CreateSphereEmitter(1)
--     local num_to_emit = 0

--     EmitterManager:AddEmitter(inst, nil, function()
--         local vel = Vector3(inst._vx:value(), inst._vy:value(), inst._vz:value())
--         if vel:Length() < 0.01 then
--             return
--         end

--         num_to_emit = num_to_emit + 1.5
--         while num_to_emit > 1 do
--             local rotate_axis = Vector3(rotate_axis_emitter()):GetNormalized()

--             local vel2 = StarIliadMath.RotateVector3(vel, rotate_axis, math.random() * 30)

--             emit_worm_fn(effect, vel2, sphere_emitter)
--             num_to_emit = num_to_emit - 1
--         end
--     end)

--     return inst
-- end

local function fn_side_hole()
    local inst = common_fn()


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    local effect = inst.VFXEffect

    effect:SetSortOrder(0, 1)

    inst.vel_fn = function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local horizontal_speed = GetRandomMinMax(0.15, 0.25)
        local vertical_speed = GetRandomMinMax(0.25, 0.35)

        local facing = parent.AnimState:GetCurrentFacing()
        local camera_right = TheCamera:GetRightVec()

        local vel = Vector3(0, 0, 0)
        if facing == FACING_RIGHT or facing == FACING_DOWNRIGHT or facing == FACING_UPRIGHT then
            vel = Vector3(-camera_right.x, 0, -camera_right.z):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        elseif facing == FACING_LEFT or facing == FACING_DOWNLEFT or facing == FACING_UPLEFT then
            vel = Vector3(camera_right.x, 0, camera_right.z):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        else
            return
        end

        return vel
    end

    return inst
end

local function fn_side_body()
    local inst = common_fn()


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    local effect = inst.VFXEffect

    inst.vel_fn = function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local horizontal_speed = GetRandomMinMax(0.15, 0.25)
        local vertical_speed = GetRandomMinMax(0.25, 0.35)

        local facing = parent.AnimState:GetCurrentFacing()
        local camera_right = TheCamera:GetRightVec()
        local camera_down = TheCamera:GetDownVec()

        local vel = Vector3(0, 0, 0)
        if facing == FACING_RIGHT or facing == FACING_DOWNRIGHT or facing == FACING_UPRIGHT then
            -- vel = Vector3(camera_right.x, 0, camera_right.z):GetNormalized() * horizontal_speed
            -- vel.y = vertical_speed
            vel = (camera_right - camera_down):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        elseif facing == FACING_LEFT or facing == FACING_DOWNLEFT or facing == FACING_UPLEFT then
            -- vel = Vector3(-camera_right.x, 0, -camera_right.z):GetNormalized() * horizontal_speed
            -- vel.y = vertical_speed
            vel = -(camera_right - camera_down):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        else
            return
        end

        return vel
    end

    return inst
end

local function fn_side_mouth()
    local inst = common_fn()


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    local effect = inst.VFXEffect
    effect:SetSortOrder(0, 1)

    inst.vel_fn = function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local horizontal_speed = GetRandomMinMax(0.15, 0.25)
        local vertical_speed = GetRandomMinMax(0.25, 0.35)

        local facing = parent.AnimState:GetCurrentFacing()
        local camera_right = TheCamera:GetRightVec()
        local camera_down = TheCamera:GetDownVec()
        local camera_pitch_down = TheCamera:GetPitchDownVec()

        local vel = Vector3(0, 0, 0)
        if facing == FACING_RIGHT or facing == FACING_DOWNRIGHT or facing == FACING_UPRIGHT then
            vel = (camera_right + camera_down * 5):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        elseif facing == FACING_LEFT or facing == FACING_DOWNLEFT or facing == FACING_UPLEFT then
            vel = (-camera_right + camera_down * 5):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        else
            return
        end

        return vel
    end

    return inst
end

local function fn_up_body()
    local inst = common_fn()


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    local effect = inst.VFXEffect

    inst.vel_fn = function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local horizontal_speed = GetRandomMinMax(0.15, 0.25)
        local vertical_speed = GetRandomMinMax(0.25, 0.35)

        local facing = parent.AnimState:GetCurrentFacing()
        local camera_right = TheCamera:GetRightVec()
        local camera_down = TheCamera:GetDownVec()
        local camera_pitch_down = TheCamera:GetPitchDownVec()

        local vel = Vector3(0, 0, 0)
        if facing == FACING_RIGHT or facing == FACING_DOWNRIGHT or facing == FACING_UPRIGHT then
            vel = (-camera_right - camera_down * 8):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        elseif facing == FACING_LEFT or facing == FACING_DOWNLEFT or facing == FACING_UPLEFT then
            vel = (camera_right - camera_down * 8):GetNormalized() * horizontal_speed
            vel.y = vertical_speed
        else
            return
        end

        return vel
    end

    return inst
end

return Prefab("stariliad_parasite_worm_fx_side_hole", fn_side_hole, assets),
    Prefab("stariliad_parasite_worm_fx_side_body", fn_side_body, assets),
    Prefab("stariliad_parasite_worm_fx_side_mouth", fn_side_mouth, assets),
    Prefab("stariliad_parasite_worm_fx_up_body", fn_up_body, assets)

-- ThePlayer:SpawnChild("stariliad_parasite_worm_fx").Transform:SetPosition(0, 2, 0)
