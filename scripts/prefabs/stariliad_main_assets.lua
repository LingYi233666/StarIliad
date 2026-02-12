local assets =
{
    -- Asset("ANIM", "anim/stariliad_gelblob_frozen.zip"),

    -- Circle ring anim
    Asset("ANIM", "anim/stariliad_autocast_ring.zip"),

    Asset("ANIM", "anim/spell_icons_blythe.zip"),

    -- Test backpack anim
    Asset("ANIM", "anim/blythe_backpack.zip"),
    -- ThePlayer.AnimState:OverrideSymbol("swap_body", "blythe_backpack", "swap_body")


    -- Common height controller
    Asset("ANIM", "anim/stariliad_height_controller.zip"),

    -- pistol shoot anim
    Asset("ANIM", "anim/player_pistol.zip"),

    Asset("ANIM", "anim/blythe_tv.zip"),

    Asset("ANIM", "anim/stariliad_cutscene_opening.zip"),

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

    Asset("IMAGE", "images/ui/skill_slot/parry.tex"),
    Asset("ATLAS", "images/ui/skill_slot/parry.xml"),

    Asset("IMAGE", "images/ui/skill_slot/stealth.tex"),
    Asset("ATLAS", "images/ui/skill_slot/stealth.xml"),

    Asset("IMAGE", "images/ui/skill_slot/dodge.tex"),
    Asset("ATLAS", "images/ui/skill_slot/dodge.xml"),

    Asset("IMAGE", "images/ui/skill_slot/scan.tex"),
    Asset("ATLAS", "images/ui/skill_slot/scan.xml"),


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
    Asset("SOUND", "sound/stariliad_sfx_lossless.fsb"),

    Asset("SOUNDPACKAGE", "sound/stariliad_music.fev"),
    Asset("SOUND", "sound/stariliad_music.fsb"),
    Asset("SOUND", "sound/stariliad_music_lossless.fsb"),
}

local function fn()
    local inst = CreateEntity()

    inst:DoTaskInTime(0, function()
        print("stariliad_main_assets is only used to load assets, it shouldn't be spawned !")
        inst:Remove()
    end)

    return inst
end

return Prefab("stariliad_main_assets", fn, assets)
