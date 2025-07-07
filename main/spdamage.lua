local SpDamageUtil = require("components/spdamageutil")


SpDamageUtil.DefineSpType("stariliad_spdamage_force", {
    GetDamage = function(ent)
        return ent.components.stariliad_spdamage_force ~= nil
            and ent.components.stariliad_spdamage_force:GetDamage() or 0
    end,
    GetDefense = function(ent)
        return ent.components.stariliad_spdefense_force ~= nil and
            ent.components.stariliad_spdefense_force:GetDefense() or 0
    end,
})

STARILIAD_DAMAGE_NUMBER_COLOURS = {
    -- GENERIC = RGB(140, 140, 140),
    -- FIRE = RGB(238, 85, 0),
    -- LIGHTNING = RGB(51, 102, 204),

    -- FORCE = RGB(204, 51, 51),

    -- PLANAR_LUNAR = RGB(204, 170, 0),
    -- PLANAR_SHADOW = RGB(64, 176, 80),
    -- PLANAR_GENERIC = RGB(140, 182, 206),

    -- PSYCHIC = RGB(204, 119, 170),

    GENERIC = RGB(255, 80, 40),
    FIRE = RGB(238, 85, 0),
    -- LIGHTNING = RGB(222, 222, 99),
    LIGHTNING = RGB(255, 255, 0),

    FORCE = RGB(204, 51, 51),

    PLANAR_LUNAR = RGB(140, 182, 206),
    PLANAR_SHADOW = RGB(204, 119, 170),
    PLANAR_GENERIC = RGB(229, 246, 255),
}

GLOBAL.STARILIAD_DAMAGE_NUMBER_COLOURS = STARILIAD_DAMAGE_NUMBER_COLOURS
