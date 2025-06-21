PrefabFiles = {
    "blythe",      --人物代码文件
    "blythe_none", --人物皮肤

    "blythe_blaster",
    "blythe_beam_basic",
    "blythe_beam_teleport",
    "blythe_beam_tail",
    "stariliad_fake_projectile",
    "stariliad_pistol_shoot_cloud",
    "blythe_beam_hit_fx",
    "blythe_beam_hit_particle",
    "blythe_missile",

    "stariliad_fake_reticule",
    "blythe_aim_reticule",
    "blythe_beam_teleport_surrounding",

    "blythe_speed_burst_particle",

    "blythe_beam_swap",
    "blythe_beam_swap_particle",

    "stariliad_normal_explode_particle",

    "blythe_clone",

    "blythe_ice_fog",
    "blythe_ice_fog_particle",

    "blythe_missile_explode_fx",

    "blythe_missile_tail",

    "stariliad_water_tail",

    -- "blythe_missile_test",

    "blythe_parry_target",
    "blythe_parry_spark",

    "blythe_beam_arrow",

    "blythe_dodge_start_circle",
    "blythe_parry_water_splash",

    "blythe_dodge_flame",

    "stariliad_debuffs",

    "stariliad_shield_break_fx",

    "blythe_scan_mark",

    "blythe_supply_ball",
    "blythe_supply_ball_tails",

    "blythe_unlock_skill_item",

    "blythe_aim_reticule2",
}

Assets = {
    -- Asset("ANIM", "anim/stariliad_gelblob_frozen.zip"),

    -- Circle ring anim
    Asset("ANIM", "anim/stariliad_autocast_ring.zip"),

    -- Common height controller
    Asset("ANIM", "anim/stariliad_height_controller.zip"),

    -- pistol shoot anim
    Asset("ANIM", "anim/player_pistol.zip"),

    -- swap beam ui
    Asset("IMAGE", "images/ui/stariliad_8star.tex"),
    Asset("ATLAS", "images/ui/stariliad_8star.xml"),

    Asset("IMAGE", "images/ui/test_powersuit_display.tex"),
    Asset("ATLAS", "images/ui/test_powersuit_display.xml"),

    Asset("IMAGE", "images/ui/stariliad_dtype_bg.tex"),
    Asset("ATLAS", "images/ui/stariliad_dtype_bg.xml"),

    Asset("IMAGE", "images/ui/stariliad_bg_upright.tex"),
    Asset("ATLAS", "images/ui/stariliad_bg_upright.xml"),

    Asset("IMAGE", "images/ui/blythe_down_view.tex"),
    Asset("ATLAS", "images/ui/blythe_down_view.xml"),

    Asset("IMAGE", "images/ui/blythe_down_view_with_gun.tex"),
    Asset("ATLAS", "images/ui/blythe_down_view_with_gun.xml"),

    Asset("IMAGE", "images/ui/stariliad_hexagon.tex"),
    Asset("ATLAS", "images/ui/stariliad_hexagon.xml"),

    Asset("IMAGE", "images/ui/stariliad_hexagon2.tex"),
    Asset("ATLAS", "images/ui/stariliad_hexagon2.xml"),

    Asset("IMAGE", "images/ui/stariliad_honeycomb.tex"),
    Asset("ATLAS", "images/ui/stariliad_honeycomb.xml"),

    Asset("IMAGE", "images/ui/stariliad_honeycomb_fill.tex"),
    Asset("ATLAS", "images/ui/stariliad_honeycomb_fill.xml"),

    Asset("IMAGE", "images/ui/stariliad_circle.tex"),
    Asset("ATLAS", "images/ui/stariliad_circle.xml"),

    Asset("IMAGE", "images/ui/stariliad_square.tex"),
    Asset("ATLAS", "images/ui/stariliad_square.xml"),

    Asset("IMAGE", "images/ui/skill_slot/unknown.tex"),
    Asset("ATLAS", "images/ui/skill_slot/unknown.xml"),

    Asset("IMAGE", "images/ui/missile_status/missile.tex"),
    Asset("ATLAS", "images/ui/missile_status/missile.xml"),

    Asset("IMAGE", "images/ui/missile_status/super_missile.tex"),
    Asset("ATLAS", "images/ui/missile_status/super_missile.xml"),

    -- swap beam ui shader
    Asset("SHADER", "shaders/8star.ksh"),

    -- Debug inventoryimage
    Asset("IMAGE", "images/inventoryimages/stariliad_debug_inventoryimage.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_debug_inventoryimage.xml"),

    -- SFX
    Asset("SOUNDPACKAGE", "sound/stariliad_sfx.fev"),
    Asset("SOUND", "sound/stariliad_sfx.fsb"),
}

GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

PREFAB_SKINS["blythe"] = { --修复人物大图显示
    "blythe_none",
}

AddMinimapAtlas("images/map_icons/blythe.xml") --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("blythe", "FEMALE")

local import_list = {
    "tuning",
    "actions",
    "language_chs",
    "basic_utils",
    "string_utils",
    "math_utils",
    "weaponskill_utils",
    "usurper_utils",
    "parry_reflect_utils",
    "spdamage",
    "rpc_defines",
    "skill_defines",
    "projectile_defines",
    "recipes",
    "components",
    "prefabs",
    "input",
    "stategraphs_server",
    "stategraphs_client",
    "hud",
    "scripts", -- not a good name
    "upvalue_utils",
    "debug",
}

for _, v in pairs(import_list) do
    modimport("main/" .. v)
end
