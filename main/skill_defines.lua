local function HandleEnableByComponent(cmp_name)
    local function fn(inst, enable, is_onload)
        inst.components[cmp_name]:Enable(enable, is_onload)
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

    {
        name = "missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
    },

    {
        name = "super_missile",
        dtype = BLYTHE_SKILL_TYPE.KINETIC,
    },

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
