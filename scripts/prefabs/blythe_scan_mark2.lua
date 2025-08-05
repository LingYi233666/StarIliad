-- local SPARKLE_TEXTURE = "fx/sparkle.tex"
-- local SPARKLE_TEXTURE = resolvefilepath("fx/blythe_scan_mark2.tex")
local SPARKLE_TEXTURE = resolvefilepath("fx/blythe_scan_mark2_white.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_GREEN = "scan_mark2_colourenvelope_green"
local COLOUR_ENVELOPE_NAME_YELLOW = "scan_mark2_colourenvelope_yellow"
local COLOUR_ENVELOPE_NAME_RED = "scan_mark2_colourenvelope_red"

local SCALE_ENVELOPE_NAME = "scan_mark2_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------
local FADEIN_DURATION = 0.33
local KEEP_TIME = 1
local FADEOUT_DURATION = 0.5
local MAX_LIFETIME = KEEP_TIME + FADEOUT_DURATION

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local p1 = FADEIN_DURATION / MAX_LIFETIME
    local p2 = KEEP_TIME / MAX_LIFETIME

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_GREEN, {
        { 0,  IntColour(0, 255, 0, 0) },
        { p1, IntColour(0, 255, 0, 255) },
        { p2, IntColour(0, 255, 0, 255) },
        { 1,  IntColour(0, 255, 0, 0) },


        -- { 0, IntColour(0, 255, 0, 255) },
        -- { 1, IntColour(0, 255, 0, 255) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_YELLOW, {
        { 0,  IntColour(255, 255, 0, 0) },
        { p1, IntColour(255, 255, 0, 255) },
        { p2, IntColour(255, 255, 0, 255) },
        { 1,  IntColour(255, 255, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_RED, {
        { 0,  IntColour(255, 0, 0, 0) },
        { p1, IntColour(255, 0, 0, 255) },
        { p2, IntColour(255, 0, 0, 255) },
        { 1,  IntColour(255, 0, 0, 0) },
    })

    local max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { max_scale, max_scale } },
            { 1, { max_scale, max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local function emit_mark_fn(effect, index, pos)
    local px, py, pz = pos:Get()

    -- local uv_offset = math.random(0, 3) * .25
    -- effect:AddParticleUV(
    --     index,
    --     MAX_LIFETIME, -- lifetime
    --     px, py, pz,   -- position
    --     0, 0, 0,      -- velocity
    --     uv_offset, 0  -- uv offset
    -- )

    effect:AddParticle(
        index,
        MAX_LIFETIME, -- lifetime
        px, py, pz,   -- position
        0, 0, 0       -- velocity
    )
end

local function AddEmitTask(inst, t, index, pos)
    table.insert(inst.emit_tasks, { t, index, pos })
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

    inst.emit_tasks = {}

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    local angle = 0
    local colour_envelopes = {
        COLOUR_ENVELOPE_NAME_GREEN,
        COLOUR_ENVELOPE_NAME_YELLOW,
        COLOUR_ENVELOPE_NAME_RED,
    }

    for k, v in pairs(colour_envelopes) do
        local i = k - 1

        -- print("Init", i, v)
        effect:SetRenderResources(i, SPARKLE_TEXTURE, ADD_SHADER)
        -- effect:SetUVFrameSize(i, .25, 1)
        effect:SetMaxNumParticles(i, 14400)
        effect:SetMaxLifetime(i, MAX_LIFETIME)
        effect:SetColourEnvelope(i, v)
        effect:SetScaleEnvelope(i, SCALE_ENVELOPE_NAME)
        effect:SetBlendMode(i, BLENDMODE.Additive)
        effect:SetSortOrder(i, 1)
        -- effect:SetSortOffset(i, 2)
        effect:SetLayer(i, LAYER_GROUND)


        effect:SetSpawnVectors(i,
            math.cos(angle), 0, math.sin(angle),
            0, 0, 1
        )
    end
    -----------------------------------------------------

    inst.AddEmitTask = AddEmitTask

    EmitterManager:AddEmitter(inst, nil, function()
        local duration = inst:GetTimeAlive()

        while #inst.emit_tasks > 0 do
            local t, index, pos = unpack(inst.emit_tasks[1])

            if t < duration then
                table.remove(inst.emit_tasks, 1)
                -- print("emit", index, pos)
                emit_mark_fn(effect, index, pos)
            else
                break
            end
        end

        -- emit_mark_fn(effect, 0, Vector3(0, 0, 0))
    end)

    return inst
end

return Prefab("blythe_scan_mark2", fn, assets)
