local function HandleEnableByComponent(cmp_name)
    local function fn(inst, enable, is_onload)
        inst.components[cmp_name]:Enable(enable, is_onload)
    end

    return fn
end

BLYTHE_SKILL_TYPES = {
    ENERGY = "ENERGY",
    KINETIC = "KINETIC",
    SUIT = "SUIT",
    MAGIC = "MAGIC",
}

BLYTHE_SKILL_DEFINES = {
    {
        name = "basic_beam",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,
        root = true,
    },

    {
        name = "ice_fog",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,
        root = true,
    },

    {
        name = "wide_beam",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,


        on_learned = function(inst, is_onload)

        end,
    },

    {
        name = "wave_beam",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,
    },

    {
        name = "plasma_beam",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,
    },

    {
        name = "usurper_shot",
        dtype = BLYTHE_SKILL_TYPES.ENERGY,
    },

    {
        name = "missile",
        dtype = BLYTHE_SKILL_TYPES.KINETIC,
    },

    {
        name = "super_missile",
        dtype = BLYTHE_SKILL_TYPES.KINETIC,
    },

    {
        name = "speed_burst",
        handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPES.SUIT,

        root = true,
    },

    {
        name = "gravity_control",
        -- handle_enable = HandleEnableByComponent("blythe_skill_speed_burst"),

        dtype = BLYTHE_SKILL_TYPES.SUIT,
    },


    {
        name = "configure_powersuit",
        dtype = BLYTHE_SKILL_TYPES.MAGIC,

        root = true,
    },
}



GLOBAL.BLYTHE_SKILL_TYPES = BLYTHE_SKILL_TYPES
GLOBAL.BLYTHE_SKILL_DEFINES = BLYTHE_SKILL_DEFINES
