local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_GREY = "stariliad_movement_dust_white_colourenvelope"

local SCALE_ENVELOPE_NAME = "stariliad_movement_dust_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_GREY,
        {
            { 0,    IntColour(103, 103, 103, 0) },
            { 0.05, IntColour(103, 103, 103, 150) },
            { 0.33, IntColour(103, 103, 103, 125) },
            { 1,    IntColour(103, 103, 103, 0) },
        }
    )

    local glow_max_scale = 0.35
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,   { glow_max_scale * 0.5, glow_max_scale * 0.5 } },
            { .55, { glow_max_scale * 1, glow_max_scale * 1 } },
            { 1,   { glow_max_scale * 0.6, glow_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local GLOW_MAX_LIFETIME = 1.7

local function emit_grow_fn(effect, emitter_fn, id, angle_velocity)
    local vx, vy, vz = .005 * UnitRand(), GetRandomMinMax(0.0, 0.07), .005 * UnitRand()
    local lifetime = GLOW_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = emitter_fn()

    angle_velocity = angle_velocity or GetRandomMinMax(3, 5) * (math.random() <= 0.5 and 1 or -1)

    effect:AddRotatingParticle(
        id,
        lifetime,            -- lifetime
        px, py + 0.2, pz,    -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        angle_velocity       -- angle velocity
    )
end

local function client_dust_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.persists = false

    if InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, GLOW_MAX_LIFETIME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    -- effect:SetSortOrder(0, 3)
    -- effect:SetSortOffset(0, 0)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, 0.05)

    return inst
end

local function client_dust_grey_fn()
    local inst = client_dust_common()

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_GREY)

    local sphere_emitter = CreateSphereEmitter(0)

    inst.num_to_emit = 0

    EmitterManager:AddEmitter(inst, nil, function()
        while inst.num_to_emit > 0 do
            emit_grow_fn(inst.VFXEffect, sphere_emitter, 0, GetRandomMinMax(2, 3.5) * (math.random() <= 0.5 and 1 or -1))
            inst.num_to_emit = inst.num_to_emit - 1
        end
    end)

    return inst
end

local function client_carrier_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

local function dust_grey_on_update(inst)
    local sparkle_desired_pps_low = 0
    local sparkle_desired_pps_high = 20

    local tick_time = TheSim:GetTickTime()
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time

    -------------------------------------------------------------------

    local cur_pos = Vector3(inst.Transform:GetWorldPosition())
    local tile, tileinfo = inst:GetCurrentTileType()
    local parent = inst.entity:GetParent()

    if tile == WORLD_TILES.STARILIAD_ASH and not (parent and parent:HasTag("flying")) then
        local dist_moved = cur_pos - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move * 6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)
        inst.num_to_emit = inst.num_to_emit + per_tick * math.random() * 3

        if move > 0.001 and not inst.SoundEmitter:PlayingSound("move") then
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/move", "move")
        elseif move <= 0.001 and inst.SoundEmitter:PlayingSound("move") then
            inst.SoundEmitter:KillSound("move")
        end
    else
        if inst.SoundEmitter:PlayingSound("move") then
            inst.SoundEmitter:KillSound("move")
        end
    end

    while inst.num_to_emit >= 1 do
        local carrier = SpawnAt("stariliad_movement_dust_carrier_client", cur_pos, nil,
            Vector3FromTheta(math.random() * TWOPI, 0.2))

        local dust = carrier:SpawnChild("stariliad_movement_dust_grey_client")
        dust.num_to_emit = 1

        inst.num_to_emit = inst.num_to_emit - 1
    end

    inst.last_pos = cur_pos
end

local function tomb_dust_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    if not TheNet:IsDedicated() then
        inst.num_to_emit = 0
        inst.last_pos = Vector3(inst.Transform:GetWorldPosition())

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(dust_grey_on_update)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-- ThePlayer:SpawnChild("stariliad_movement_dust_grey")
return Prefab("stariliad_movement_dust_carrier_client", client_carrier_fn, assets),
    Prefab("stariliad_movement_dust_grey_client", client_dust_grey_fn, assets),
    Prefab("stariliad_movement_dust_necrons_tomb", tomb_dust_fn, assets)
