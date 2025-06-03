local FIRE_TEXTURE = "fx/torchfire.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_FIRE = "blythe_dodge_flame_colourenvelope"
local SCALE_ENVELOPE_NAME_FIRE = "blythe_dodge_flame_scaleenvelope"

local assets =
{
    Asset("IMAGE", FIRE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_FIRE,
        {
            -- { 0,   IntColour(187, 111, 60, 128) },
            -- { .49, IntColour(187, 111, 60, 128) },
            -- { .5,  IntColour(255, 255, 0, 128) },
            -- { .51, IntColour(255, 30, 56, 128) },
            -- { .75, IntColour(255, 30, 56, 128) },
            -- { 1,   IntColour(255, 7, 28, 0) },

            -- { 0,   IntColour(122, 30, 255, 255) },
            -- { .5,  IntColour(122, 20, 255, 255) },
            -- { .75, IntColour(122, 10, 255, 255) },
            -- { 1,   IntColour(200, 5, 255, 255) },

            { 0,   IntColour(30, 122, 255, 255) },
            { .5,  IntColour(20, 122, 255, 255) },
            { .75, IntColour(10, 122, 255, 255) },
            { 1,   IntColour(5, 200, 255, 255) },

        }
    )

    local max_scale = 4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_FIRE,
        {
            { 0, { max_scale * .5, max_scale } },
            { 1, { max_scale * 0.25, max_scale * .5 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_FIRE = 1

local function emit_fn(effect, sphere_emitter, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = MAX_LIFETIME_FIRE * (.9 + UnitRand() * .1)
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
    effect:InitEmitters(1)

    effect:SetRenderResources(0, FIRE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, MAX_LIFETIME_FIRE)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FIRE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FIRE)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetRotateOnVelocity(0, true)
    -- effect:SetSortOrder(0, -1)
    effect:SetSortOffset(0, -1)
    effect:SetFollowEmitter(0, true)
    effect:SetDragCoefficient(0, 1000)

    -----------------------------------------------------

    local sphere_emitter = CreateSphereEmitter(.05)


    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local facing = parent.AnimState:GetCurrentFacing()


        local velocity = -StarIliadBasic.GetFaceVector(parent) * 0.01

        -- if facing ~= FACING_UP and
        --     facing ~= FACING_UPRIGHT and
        --     facing ~= FACING_UPLEFT then
        --     self.breath.Transform:SetPosition(self:GetOffset())
        --     self.breath:Emit()
        -- end

        if table.contains({ FACING_UP, FACING_UPLEFT, FACING_UPRIGHT }, facing) then
            effect:SetSortOffset(0, 1)
        else
            effect:SetSortOffset(0, -1)
        end



        for i = 1, 5 do
            emit_fn(effect, sphere_emitter, velocity)
        end
    end)

    return inst
end

return Prefab("blythe_dodge_flame", fn, assets)
