PrefabFiles = {
    "blythe",      --人物代码文件
    "blythe_none", --人物皮肤

    "blythe_blaster",
    "blythe_beam_basic",
    "blythe_beam_basic_tail",
    "stariliad_fake_projectile",
    "stariliad_pistol_shoot_cloud",
    "blythe_beam_hit_fx",
    "blythe_beam_hit_particle",
    "blythe_missile",

    "stariliad_fake_reticule",
}

Assets = {
    -- Common height controller
    Asset("ANIM", "anim/stariliad_height_controller.zip"),

    -- pistol shoot anim
    Asset("ANIM", "anim/player_pistol.zip"),

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
    "math_utils",
    "weaponskill_utils",
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
    "debug",
}

for _, v in pairs(import_list) do
    modimport("main/" .. v)
end
