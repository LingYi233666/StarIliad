local function HandleEnableByComponent(cmp_name)
    local function fn(inst, enable, is_onload)
        inst.components[cmp_name]:Enable(enable, is_onload)
    end

    return fn
end

local function CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    local cmp = inst.components[cmp_name]

    if cmp then
        local can_cast, reason = cmp:CanCast(x, y, z, ent)

        if can_cast then
            cmp:Cast(x, y, z, ent)
        else
            print(cmp_name .. " cast failed, reason: " .. tostring(reason))
        end
    end
end

local function CastSkillByComponentWrapper(cmp_name)
    local function fn(inst, x, y, z, ent)
        CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    end

    return fn
end


BLYTHE_SKILL_TYPE = {
    ENERGY = "ENERGY",
    KINETIC = "KINETIC",
    SUIT = "SUIT",
    MAGIC = "MAGIC",
}

BLYTHE_SKILL_DEFINES = {
    -- ENERGY
    {
        name = "basic_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        root = true,
    },

    {
        name = "ice_fog",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
        root = true,
    },

    {
        name = "wide_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
    },

    {
        name = "wave_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
    },

    {
        name = "plasma_beam",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
    },

    {
        name = "usurper_shot",
        dtype = BLYTHE_SKILL_TYPE.ENERGY,
    },

    -- KINETIC
    {
        name = "missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
    },

    {
        name = "super_missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
    },

    -- {
    --     name = "big_fucking_missile",
    --     dtype = BLYTHE_SKILL_TYPE.KINETIC,
    -- },

    -- SUIT
    {
        name = "speed_burst",
        handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPE.SUIT,

        root = true,
    },

    {
        name = "gravity_control",
        -- handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPE.SUIT,
    },

    -- MAGIC
    {
        name = "configure_powersuit",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        root = true,

        on_pressed_client = function(inst)
            if inst.replica.blythe_powersuit_configure then
                inst.replica.blythe_powersuit_configure:TryOpenWheel()
            end
        end,
    },

    {
        name = "dodge",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        root = true,

        on_pressed = CastSkillByComponentWrapper("blythe_skill_dodge")
    },

    {
        name = "parry",
        dtype = BLYTHE_SKILL_TYPE.MAGIC,

        root = true,

        -- on_pressed_client = function(inst, x, y, z)
        --     if not (inst.sg and inst.sg.sg and inst.sg.sg.name == "wilson_client") then
        --         return
        --     end

        --     if inst:HasTag("nopredict") or inst:HasTag("pausepredict") then
        --         return
        --     end

        --     if IsEntityDeadOrGhost(inst, true) then
        --         return
        --     end

        --     if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt") then
        --         return
        --     end

        --     if inst.replica.rider and inst.replica.rider:IsRiding() then
        --         return
        --     end

        --     if not (inst.replica.hunger and inst.replica.hunger:GetCurrent() >= 1) then
        --         return
        --     end

        --     inst.sg:GoToState("blythe_parry", { pos = Vector3(x, y, z) })
        -- end,

        on_pressed = CastSkillByComponentWrapper("blythe_skill_parry")
    },
}

-- Test
-- for i = 1, 60 do
--     table.insert(BLYTHE_SKILL_DEFINES, {
--         name = "test_" .. tostring(i),
--         dtype = BLYTHE_SKILL_TYPE.MAGIC,
--     })
-- end


GLOBAL.BLYTHE_SKILL_TYPE = BLYTHE_SKILL_TYPE
GLOBAL.BLYTHE_SKILL_DEFINES = BLYTHE_SKILL_DEFINES
