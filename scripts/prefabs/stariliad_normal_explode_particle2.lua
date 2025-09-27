local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local EMBER_TEXTURE = "fx/snow.tex"
local CIRCLE_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", CIRCLE_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end


local function MakeNormalExplode(prefab, envelopes, num_particles, speeds, spawn_radius, post_init)
    num_particles = num_particles or {}
    speeds = speeds or {} -- TODO: Add speeds support
    spawn_radius = spawn_radius or {}

    local COLOUR_ENVELOPE_NAME_EMBER = prefab .. "_colourenvelope_ember"
    local SCALE_ENVELOPE_NAME_EMBER = prefab .. "_scaleenvelope_ember"

    local COLOUR_ENVELOPE_NAME_AROUND_SMOKE = prefab .. "_colourenvelope_around_smoke"
    local SCALE_ENVELOPE_NAME_AROUND_SMOKE = prefab .. "_scaleenvelope_around_smoke"

    local COLOUR_ENVELOPE_NAME_MIDDLE_CIRCLE = prefab .. "_colourenvelope_middle_middle_circle"
    local SCALE_ENVELOPE_NAME_MIDDLE_CIRCLE = prefab .. "_scaleenvelope_middle_middle_circle"

    local COLOUR_ENVELOPE_NAME_MIDDLE_SMOKE = prefab .. "_colourenvelope_middle_smoke"
    local SCALE_ENVELOPE_NAME_MIDDLE_SMOKE = prefab .. "_scaleenvelope_middle_smoke"

    local COLOUR_ENVELOPE_NAME_ARROW = prefab .. "_colourenvelope_arrow"
    local SCALE_ENVELOPE_NAME_ARROW = prefab .. "_scaleenvelope_arrow"

    local EMBER_MAX_LIFETIME = 3
    local AROUND_SMOKE_MAX_LIFETIME = 2
    local MIDDLE_CIRCLE_MAX_LIFETIME = 0.6
    local MIDDLE_SMOKE_MAX_LIFETIME = 0.5
    local ARROW_MAX_LIFETIME = 1

    local num_emitters = GetTableSize(envelopes)
    local name_index_tab = {}

    local counter = 0
    for name, data in pairs(envelopes) do
        name_index_tab[name] = counter
        counter = counter + 1
    end

    local function InitEnvelope()
        if envelopes.ember then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_EMBER, envelopes.ember.colour)
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_EMBER, envelopes.ember.scale)
        end

        if envelopes.around_smoke then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_AROUND_SMOKE, envelopes.around_smoke.colour)
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_AROUND_SMOKE, envelopes.around_smoke.scale)
        end

        if envelopes.middle_circle then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_MIDDLE_CIRCLE, envelopes.middle_circle.colour)
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_MIDDLE_CIRCLE, envelopes.middle_circle.scale)
        end

        if envelopes.middle_smoke then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_MIDDLE_SMOKE, envelopes.middle_smoke.colour)
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_MIDDLE_SMOKE, envelopes.middle_smoke.scale)
        end

        if envelopes.arrow then
            EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, envelopes.arrow.colour)
            EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_ARROW, envelopes.arrow.scale)
        end

        InitEnvelope = nil
    end

    local function InitEmitters(inst)
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(num_emitters)

        print("num_emitters:", num_emitters)

        for name, index in pairs(name_index_tab) do
            if name == "ember" then
                -- Ember
                effect:SetRenderResources(index, EMBER_TEXTURE, ADD_SHADER)
                effect:SetMaxNumParticles(index, 128)
                effect:SetMaxLifetime(index, EMBER_MAX_LIFETIME)
                effect:SetColourEnvelope(index, COLOUR_ENVELOPE_NAME_EMBER)
                effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_EMBER)
                effect:SetBlendMode(index, BLENDMODE.Additive)
                effect:EnableBloomPass(index, true)
                effect:SetSortOffset(index, 0)
                effect:SetDragCoefficient(index, .2)
            elseif name == "around_smoke" then
                -- Around smoke
                effect:SetRenderResources(index, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
                effect:SetMaxNumParticles(index, 64)
                effect:SetRotationStatus(index, true)
                effect:SetMaxLifetime(index, AROUND_SMOKE_MAX_LIFETIME)
                effect:SetColourEnvelope(index, COLOUR_ENVELOPE_NAME_AROUND_SMOKE)
                effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_AROUND_SMOKE)
                effect:SetBlendMode(index, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
                --effect:EnableBloomPass(index, true)
                --effect:SetUVFrameSize(index, .25, 1)
                effect:SetSortOffset(index, 0)
                effect:SetRadius(index, 3) --only needed on a single emitter
                effect:SetDragCoefficient(index, .1)
            elseif name == "middle_circle" then
                -- Middle circle
                effect:SetRenderResources(index, CIRCLE_TEXTURE, ADD_SHADER)
                effect:SetMaxNumParticles(index, 1)
                effect:SetRotationStatus(index, true)
                effect:SetUVFrameSize(index, 0.25, 1)
                effect:SetMaxLifetime(index, MIDDLE_CIRCLE_MAX_LIFETIME)
                effect:SetColourEnvelope(index, COLOUR_ENVELOPE_NAME_MIDDLE_CIRCLE)
                effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_MIDDLE_CIRCLE)
                effect:SetBlendMode(index, BLENDMODE.Additive) --AlphaBlended Premultiplied
                effect:SetSortOffset(index, 2)
                -- effect:SetRadius(index, 3) --only needed on a single emitter
                effect:SetDragCoefficient(index, .1)
            elseif name == "middle_smoke" then
                -- Middle smoke
                effect:SetRenderResources(index, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
                effect:SetMaxNumParticles(index, 1)
                effect:SetRotationStatus(index, true)
                effect:SetMaxLifetime(index, MIDDLE_SMOKE_MAX_LIFETIME)
                effect:SetColourEnvelope(index, COLOUR_ENVELOPE_NAME_MIDDLE_SMOKE)
                effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_MIDDLE_SMOKE)
                effect:SetBlendMode(index, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
                --effect:EnableBloomPass(index, true)
                --effect:SetUVFrameSize(index, .25, 1)
                effect:SetSortOffset(index, 0)
                effect:SetRadius(index, 3) --only needed on a single emitter
                effect:SetDragCoefficient(index, .1)
            elseif name == "arrow" then
                -- Arrow
                effect:SetRenderResources(index, ARROW_TEXTURE, ADD_SHADER)
                effect:SetMaxNumParticles(index, 25)
                effect:SetMaxLifetime(index, ARROW_MAX_LIFETIME)
                effect:SetColourEnvelope(index, COLOUR_ENVELOPE_NAME_ARROW)
                effect:SetScaleEnvelope(index, SCALE_ENVELOPE_NAME_ARROW)
                effect:SetBlendMode(index, BLENDMODE.Additive)
                effect:EnableBloomPass(index, true)
                effect:SetUVFrameSize(index, 0.25, 1)
                effect:SetSortOffset(index, 0)
                effect:SetDragCoefficient(index, .14)
                effect:SetRotateOnVelocity(index, true)
                -- effect:SetAcceleration(index, 0, -0.3, 0)
            end
        end

        return effect
    end

    ---------------------------------------------------------------------------------

    local function emit_ember_fn(effect, index, sphere_emitter)
        local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
        local px, py, pz = sphere_emitter()
        local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.7, 0.9)
        local vx, vy, vz = (vec + Vector3(0, GetRandomMinMax(0.04, 0.17), 0)):Get()

        effect:AddParticle(
            0,
            lifetime,        -- lifetime
            px, py + .4, pz, -- position
            vx, vy, vz       -- velocity
        )
    end

    local function emit_around_smoke_fn(effect, index, sphere_emitter)
        local vx, vy, vz = .2 * UnitRand(), .1 + .1 * UnitRand(), .2 * UnitRand()
        local lifetime = AROUND_SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
        local px, py, pz = sphere_emitter()

        effect:AddRotatingParticle(
            index,
            lifetime,            -- lifetime
            px, py + .5, pz,     -- position
            vx, vy, vz,          -- velocity
            math.random() * 360, --* 2 * PI, -- angle
            UnitRand() * 2       -- angle velocity
        )
    end

    local function emit_middle_circle_fn(effect, index)
        local vx, vy, vz = 0, 0, 0
        local lifetime = MIDDLE_CIRCLE_MAX_LIFETIME * (.9 + math.random() * .1)
        local px, py, pz = 0, 0, 0

        effect:AddRotatingParticle(
            index,
            lifetime,            -- lifetime
            px, py + .4, pz,     -- position
            vx, vy, vz,          -- velocity
            math.random() * 360, --* 2 * PI, -- angle
            UnitRand() * 0.1     -- angle velocity
        )
    end

    local function emit_middle_smoke_fn(effect, index)
        local vx, vy, vz = 0, 0, 0
        local lifetime = MIDDLE_SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
        local px, py, pz = 0, 0, 0

        effect:AddRotatingParticle(
            index,
            lifetime,            -- lifetime
            px, py + .7, pz,     -- position
            vx, vy, vz,          -- velocity
            math.random() * 360, --* 2 * PI, -- angle
            UnitRand() * 2.5     -- angle velocity
        )
    end

    local function emit_arrow_fn(effect, index, sphere_emitter)
        local lifetime = ARROW_MAX_LIFETIME * (0.7 + math.random() * .3)
        local px, py, pz = sphere_emitter()
        local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.5, 0.6)
        local vx, vy, vz = vec:Get()

        local uv_offset = math.random(0, 3) * .25

        effect:AddParticleUV(
            index,
            lifetime,        -- lifetime
            px, py + .4, pz, -- position
            vx, vy, vz,      -- velocity
            uv_offset, 0     -- uv offset
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

        inst.name_index_tab = name_index_tab
        inst.emitted = false

        local effect = InitEmitters(inst)

        local ember_sphere_emitter = CreateSphereEmitter(spawn_radius.ember or 0.15)
        local around_smoke_sphere_emitter = CreateSphereEmitter(spawn_radius.around_smoke or 0.2)
        local arrow_sphere_emitter = CreateSphereEmitter(spawn_radius.arrow or 0.1)

        EmitterManager:AddEmitter(inst, nil, function()
            -- print("start AddEmitter")

            local parent = inst.entity:GetParent()
            if not parent then
                return
            end

            if inst.emitted then
                return
            end

            local time_alive = inst:GetTimeAlive()

            if time_alive > FRAMES then
                print("do emit !")
                if name_index_tab.ember then
                    for i = 1, (num_particles.ember or 80) do
                        emit_ember_fn(effect, name_index_tab.ember, ember_sphere_emitter)
                    end
                end

                if name_index_tab.around_smoke then
                    for i = 1, (num_particles.around_smoke or 75) do
                        emit_around_smoke_fn(effect, name_index_tab.around_smoke, around_smoke_sphere_emitter)
                    end
                end

                if name_index_tab.middle_circle then
                    for i = 1, (num_particles.middle_circle or 1) do
                        emit_middle_circle_fn(effect, name_index_tab.middle_circle)
                    end
                end

                if name_index_tab.middle_smoke then
                    for i = 1, (num_particles.middle_smoke or 1) do
                        emit_middle_smoke_fn(effect, name_index_tab.middle_smoke)
                    end
                end

                if name_index_tab.arrow then
                    for i = 1, (num_particles.arrow or 25) do
                        emit_arrow_fn(effect, name_index_tab.arrow, arrow_sphere_emitter)
                    end
                end

                inst.emitted = true
            end
        end)

        if post_init then
            post_init(inst)
        end

        return inst
    end

    return Prefab(prefab, fn, assets)
end

--------------------------------------------------------------------------------

local ember_max_scale = 0.8
local around_smoke_max_scale = 0.5
local middle_circle_max_scale = 15
local middle_smoke_max_scale = 1.5
local arrow_max_scale = 2.25


local function CreateBlueEmberColour()
    local ember_colour_envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(ember_colour_envs, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(ember_colour_envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(ember_colour_envs, { 1, IntColour(0, 229, 232, 0) })

    return ember_colour_envs
end
local around_smoke2_max_scale = 0.5


local dataset = {
    stariliad_normal_explode_particle = {
        envelopes = {
            ember = {
                colour = {
                    { 0,    IntColour(200, 85, 60, 25) },
                    { .075, IntColour(230, 140, 90, 200) },
                    { .3,   IntColour(255, 90, 70, 255) },
                    { .6,   IntColour(255, 90, 70, 255) },
                    { .9,   IntColour(255, 90, 70, 230) },
                    { 1,    IntColour(255, 70, 70, 0) },
                },
                scale  = {
                    { 0, { ember_max_scale, ember_max_scale } },
                    { 1, { ember_max_scale * 0.2, ember_max_scale * 0.2 } },
                },
            },

            around_smoke = {
                colour = {
                    { 0,   IntColour(10, 10, 10, 0) },
                    { 0.1, IntColour(10, 10, 10, 10) },
                    { .3,  IntColour(10, 10, 10, 175) },
                    { .52, IntColour(10, 10, 10, 90) },
                    { 1,   IntColour(10, 10, 10, 0) },
                },
                scale  = {
                    { 0, { around_smoke_max_scale * .5, around_smoke_max_scale * .5 } },
                    { 1, { around_smoke_max_scale, around_smoke_max_scale } },
                },
            },

            middle_circle = {
                colour = {
                    { 0,    IntColour(255, 90, 70, 0) },
                    { .075, IntColour(255, 90, 70, 255) },
                    { .3,   IntColour(200, 85, 60, 60) },
                    { .6,   IntColour(230, 140, 90, 50) },
                    { .9,   IntColour(255, 90, 70, 25) },
                    { 1,    IntColour(255, 70, 70, 0) },
                },
                scale  = {
                    { 0, { middle_circle_max_scale, middle_circle_max_scale } },
                    { 1, { middle_circle_max_scale * 1.1, middle_circle_max_scale * 1.1 } },
                },
            },

            middle_smoke = {
                colour = {
                    { 0,  IntColour(255, 90, 70, 0) },
                    { .2, IntColour(255, 120, 90, 240) },
                    { .3, IntColour(200, 85, 60, 60) },
                    { .6, IntColour(230, 140, 90, 50) },
                    { .9, IntColour(255, 90, 70, 25) },
                    { 1,  IntColour(255, 70, 70, 0) },
                },
                scale  = {
                    { 0, { middle_smoke_max_scale, middle_smoke_max_scale } },
                    { 1, { middle_smoke_max_scale * 1.1, middle_smoke_max_scale * 1.1 } },
                },
            },

            arrow = {
                colour = {
                    { 0,  IntColour(255, 90, 70, 180) },
                    { .2, IntColour(255, 120, 90, 255) },
                    { .6, IntColour(255, 90, 70, 175) },
                    { 1,  IntColour(0, 0, 0, 0) },
                },
                scale  = {
                    { 0, { arrow_max_scale, arrow_max_scale } },
                    { 1, { arrow_max_scale * 0.125, arrow_max_scale * 0.8 } },
                },
            },
        },

        num_particles = {
            ember = 80,
            around_smoke = 75,
            arrow = 25,
        },

        -- Currently not used
        -- speeds = {
        --     ember = 0,
        --     around_smoke = 0,
        --     arrow = 0,
        -- },

        spawn_radius = {
            ember = 0.15,
            around_smoke = 0.2,
            arrow = 0.1,
        },
    },

    stariliad_small_explode_particle = {
        envelopes = {
            ember = {
                colour = {
                    { 0,    IntColour(200, 85, 60, 25) },
                    { .075, IntColour(230, 140, 90, 200) },
                    { .3,   IntColour(255, 90, 70, 255) },
                    { .6,   IntColour(255, 90, 70, 255) },
                    { .9,   IntColour(255, 90, 70, 230) },
                    { 1,    IntColour(255, 70, 70, 0) },
                },
                scale  = {
                    { 0, { ember_max_scale, ember_max_scale } },
                    { 1, { ember_max_scale * 0.2, ember_max_scale * 0.2 } },
                },
            },

            around_smoke = {
                colour = {
                    { 0,   IntColour(10, 10, 10, 0) },
                    { .1,  IntColour(10, 10, 10, 175) },
                    { .52, IntColour(10, 10, 10, 90) },
                    { 1,   IntColour(10, 10, 10, 0) },
                },
                scale  = {
                    { 0, { around_smoke_max_scale * .5, around_smoke_max_scale * .5 } },
                    { 1, { around_smoke_max_scale, around_smoke_max_scale } },
                },
            },
        },

        num_particles = {
            ember = 9,
            around_smoke = 9,
        },

        spawn_radius = {
            ember = 0.07,
            around_smoke = 0.1,
        },

        post_init = function(inst)
            inst.VFXEffect:SetDragCoefficient(inst.name_index_tab.ember, 0.4)
            inst.VFXEffect:SetSortOrder(inst.name_index_tab.ember, 0)

            inst.VFXEffect:SetDragCoefficient(inst.name_index_tab.around_smoke, 0.2)
            inst.VFXEffect:SetSortOrder(inst.name_index_tab.around_smoke, 0)
        end,
    },

    stariliad_small_explode_blue_particle = {
        envelopes = {
            ember = {
                colour = CreateBlueEmberColour(),
                scale  = {
                    { 0, { ember_max_scale, ember_max_scale } },
                    { 1, { ember_max_scale * 0.2, ember_max_scale * 0.2 } },
                },
            },

            around_smoke = {
                colour = {
                    { 0,  IntColour(255, 240, 255, 0) },
                    { .2, IntColour(255, 253, 255, 240) },
                    { .3, IntColour(200, 255, 255, 60) },
                    { .6, IntColour(230, 245, 245, 50) },
                    { .9, IntColour(255, 240, 245, 25) },
                    { 1,  IntColour(255, 240, 244, 0) },
                },
                scale  = {
                    { 0, { around_smoke2_max_scale, around_smoke2_max_scale } },
                    { 1, { around_smoke2_max_scale * 1.1, around_smoke2_max_scale * 1.1 } },
                },
            },
        },

        num_particles = {
            ember = 9,
            around_smoke = 9,
        },

        spawn_radius = {
            ember = 0.07,
            around_smoke = 0.1,
        },

        post_init = function(inst)
            inst.VFXEffect:SetDragCoefficient(inst.name_index_tab.ember, 0.4)
            inst.VFXEffect:SetSortOrder(inst.name_index_tab.ember, 0)

            inst.VFXEffect:SetDragCoefficient(inst.name_index_tab.around_smoke, 0.2)
            inst.VFXEffect:SetSortOrder(inst.name_index_tab.around_smoke, 0)
        end,
    },
}

local rets = {}
for name, data in pairs(dataset) do
    table.insert(rets,
        MakeNormalExplode(name, data.envelopes, data.num_particles, data.speeds, data.spawn_radius, data.post_init))
end

return unpack(rets)
