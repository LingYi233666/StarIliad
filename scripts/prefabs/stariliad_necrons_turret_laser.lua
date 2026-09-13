local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

-- local COLOUR_ENVELOPE_NAME_SMOKE_BLUE = "blythe_beam_swap_segment_particle_colourenvelope_smoke_blue"
-- local COLOUR_ENVELOPE_NAME_SMOKE_YELLOW = "blythe_beam_swap_segment_particle_colourenvelope_smoke_yellow"
-- local COLOUR_ENVELOPE_NAME_ARROW = "blythe_beam_swap_segment_particle_colourenvelope_arrow"
-- local COLOUR_ENVELOPE_NAME_BLACK_SMOKE = "blythe_beam_swap_segment_particle_colourenvelope_black_smoke"

-- local SCALE_ENVELOPE_NAME_SMOKE_THIN = "blythe_beam_swap_segment_particle_scaleenvelope_smoke_thin"
-- local SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN = "blythe_beam_swap_segment_particle_scaleenvelope_smoke_very_thin"
-- local SCALE_ENVELOPE_NAME_SMOKE = "blythe_beam_swap_segment_particle_scaleenvelope_smoke"
-- local SCALE_ENVELOPE_NAME_ARROW = "blythe_beam_swap_segment_particle_scaleenvelope_arrow"
-- local SCALE_ENVELOPE_NAME_BLACK_SMOKE = "blythe_beam_swap_segment_particle_scaleenvelope_black_smoke"


local COLOUR_ENVELOPE_NAME_SMOKE_GREEN = "stariliad_necrons_turret_laser_segment_particle_colourenvelope_smoke_green"
local COLOUR_ENVELOPE_NAME_ARROW = "stariliad_necrons_turret_laser_segment_particle_colourenvelope_arrow"

local SCALE_ENVELOPE_NAME_SMOKE_1 = "stariliad_necrons_turret_laser_segment_particle_scaleenvelope_smoke_1"
local SCALE_ENVELOPE_NAME_SMOKE_2 = "stariliad_necrons_turret_laser_segment_particle_scaleenvelope_smoke_2"
local SCALE_ENVELOPE_NAME_ARROW = "stariliad_necrons_turret_laser_segment_particle_scaleenvelope_arrow"

local assets =
{
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
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_GREEN, {
        { 0,  IntColour(43, 240, 31, 0) },
        { .2, IntColour(43, 253, 31, 200) },
        { .3, IntColour(43, 255, 31, 110) },
        { .6, IntColour(43, 245, 31, 180) },
        { .9, IntColour(43, 240, 31, 100) },
        { 1,  IntColour(43, 240, 31, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,  IntColour(43, 240, 31, 0) },
        { .2, IntColour(43, 253, 31, 200) },
        { .3, IntColour(43, 255, 31, 110) },
        { .6, IntColour(43, 245, 31, 180) },
        { .9, IntColour(43, 240, 31, 100) },
        { 1,  IntColour(43, 240, 31, 0) },
    })

    local smoke_1_max_scale = 0.75
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_1,
        {
            { 0,   { smoke_1_max_scale * 0.12, smoke_1_max_scale } },
            { 0.2, { smoke_1_max_scale * 0.12, smoke_1_max_scale } },
            { 1,   { smoke_1_max_scale * .01, smoke_1_max_scale * 0.6 } },
        }
    )

    local smoke_2_max_scale = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_2,
        {
            { 0,   { smoke_2_max_scale * 0.07, smoke_2_max_scale } },
            { 0.2, { smoke_2_max_scale * 0.07, smoke_2_max_scale } },
            { 1,   { smoke_2_max_scale * .005, smoke_2_max_scale * 0.6 } },
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


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.6
local MAX_LIFETIME_ARROW = 1.0

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


local function particle_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddNetwork()

    inst:AddTag("FX")

    -- client-side entity
    -- inst.entity:SetPristine()

    inst.persists = false


    -- inst._forward_x = net_float(inst.GUID, "stariliad_necrons_turret_laser_segment_particle._forward_x")
    -- inst._forward_y = net_float(inst.GUID, "stariliad_necrons_turret_laser_segment_particle._forward_y")
    -- inst._forward_z = net_float(inst.GUID, "stariliad_necrons_turret_laser_segment_particle._forward_z",
    --     "forward_z_dirty")

    -- if not TheNet:IsDedicated() then
    --     inst:ListenForEvent("forward_z_dirty", function()
    --         inst.num_to_emit = 3
    --     end)
    -- end

    inst.forward = Vector3(0, 0, 0)
    inst.num_to_emit = 0

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
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_GREEN)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_1)
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
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_GREEN)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_2)
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

        if time_alive > FRAMES then
            while inst.num_to_emit > 0 do
                -- local forward = StarIliadBasic.GetFaceVector(parent)
                -- local forward = Vector3(inst._forward_x:value(), inst._forward_y:value(), inst._forward_z:value())
                --     :GetNormalized()

                local velocity = inst.forward:GetNormalized() * 0.3
                emit_line_thin(effect, Vector3(line_sphere_emitter()), velocity)

                for i = 1, 2 do
                    emit_line(effect, Vector3(line_sphere_emitter()), velocity)
                end
                for i = 1, 4 do
                    emit_arrow(effect, Vector3(arrow_sphere_emitter()), velocity)
                end

                inst.num_to_emit = inst.num_to_emit - 1
            end
        end
    end)

    return inst
end

---------------------------------------------------------------------------------------------

-- local function LaunchLaser(inst, target_pos)
--     -- local segment = inst:SpawnChild("stariliad_necrons_turret_laser_segment_particle")
--     -- segment._forward_x:set(inst.Transform:GetRotation())
--     -- segment._forward_y:set(0)
--     -- segment._forward_z:set(1)

--     local seg_dist = 1.0
--     local start_offset = 0.0
--     local end_offset = 0.0


--     local start_pos = inst:GetPosition()
--     local delta = target_pos - start_pos

--     local dir = delta:GetNormalized()
--     local dist = delta:Length()

--     for cur_dist = start_offset, dist + end_offset, seg_dist do
--         local cur_pos = start_pos + dir * cur_dist
--         local segment = inst:SpawnChild("stariliad_necrons_turret_laser_segment_particle")
--         segment._forward_x:set(inst.Transform:GetRotation())
--         segment._forward_y:set(0)
--         segment._forward_z:set(1)
--     end
-- end

local function segment_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    -- client-side entity

    inst:AddTag("FX")

    inst.persists = false

    inst.fx = inst:SpawnChild("stariliad_necrons_turret_laser_segment_particle")

    inst.EmitFX = function(inst, forward)
        inst.fx.forward = forward
        inst.fx.num_to_emit = 3
    end

    inst.SetGroundDepth = function()
        inst.fx.VFXEffect:EnableDepthTest(0, true)
        inst.fx.VFXEffect:EnableDepthTest(1, true)
        inst.fx.VFXEffect:EnableDepthTest(2, true)
    end

    inst:DoTaskInTime(0.1, inst.Remove)

    return inst
end

return Prefab("stariliad_necrons_turret_laser_segment_particle", particle_fn, assets),
    Prefab("stariliad_necrons_turret_laser_segment", segment_fn, assets)
