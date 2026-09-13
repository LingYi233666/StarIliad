local scrapbookdata = require("screens/redux/scrapbookdata")

local STARILIAD_SCRAPBOOK_DATA = {
    -- sample = {
    --     type = "item", -- 见下方分类
    --     -- 可选：
    --     subcat = "weapon",
    --     build = "my_item",
    --     bank = "my_item",
    --     anim = "idle",
    --     specialinfo = "MY_ITEM",     -- 背景/机制介绍的 key
    --     deps = { "twigs", "flint" }, -- 相关物品链接
    --     -- 物品/食物常见：stacksize, weapondamage, hungervalue...
    --     -- 生物常见：health, damage, sanityaura...
    -- },

    -- worm_boss = {

    --     type = "giant",

    --     health = 5000,
    --     damage = 14,

    --     build = "worm_boss",
    --     bank = "worm_boss",
    --     anim = "head_idle_loop",
    --     deps = { "monstermeat", "sketch", "winter_ornament_boss_wormboss", "wormlight" }
    -- },


    -- lunarplanthat = {
    --     subcat = "armor",
    --     type = "item",

    --     armor = 830,
    --     absorb_percent = 0.8,
    --     armor_planardefense = 10,

    --     forgerepairable = { "lunarplant_kit" },

    --     build = "hat_lunarplant",
    --     bank = "lunarplanthat",
    --     anim = "anim",

    --     waterproofer = 0.35,
    --     deps = { "lunarplant_husk", "lunarplant_kit", "purebrilliance" }
    -- },


    blythe                                 = {
        type = "creature",
        -- subcat = "weapon",

        bank = "wilson",
        build = "blythe",
        anim = "idle",
        facing = FACING_DOWN,
        scale = 1.3,
        animoffsetx = 30,

        hide = { "ARM_carry", "HAT", "HAIR_HAT", "HEAD_HAT" },

        health = TUNING.BLYTHE_HEALTH,

        -- finiteuses = TUNING.BLYTHE_BLASTER_USES,
        -- forgerepairable = { "blythe_blaster_repair_kit" },

        -- weapondamage = string.format("%d-%d", TUNING.BLYTHE_BEAM_BASIC_DAMAGE, TUNING.BLYTHE_SUPER_MISSILE_DAMAGE),

        deps = { "stariliad_dataset_note_blythe_mission", "blythe_blaster", "blythe_backpack", "stariliad_hat_green_glass_helmet" },

        -- craftingprefab = "blythe",

        init_unlock = true,
    },

    stariliad_dataset_note_blythe_mission  = {
        type = "item",

        tex = "wagstaff_mutations_note.tex",
        manual_register_tex = true,

        build = "wagstaff_notes",
        bank = "wagstaff_notes",
        anim = "idle",

        deps = { "stariliad_dataset_note_enzu" },

        init_unlock = true,
    },

    stariliad_dataset_note_ancient_war     = {
        type = "item",

        tex = "wagstaff_mutations_note.tex",
        manual_register_tex = true,

        build = "stariliad_scrapbook",
        bank = "stariliad_scrapbook",
        anim = "sample",
        scale = 2,
        animoffsetx = 75,
        animoffsety = -40,
        animoffsetbgx = 120,
        animoffsetbgy = 60,

        init_unlock = true,

        deps = { "stariliad_dataset_note_enzu" },
    },

    stariliad_dataset_note_enzu            = {
        type = "item",

        tex = "wagstaff_mutations_note.tex",
        manual_register_tex = true,

        build = "wagstaff_notes",
        bank = "wagstaff_notes",
        anim = "idle",

        -- weapondamage = "NaN",
        -- planardamage = "NaN",
        weapondamage = math.huge,
        planardamage = math.huge,

        init_unlock = true,

        notes = { lunar_aligned = true },
    },

    stariliad_dataset_note_chozo           = {
        type = "item",

        tex = "wagstaff_mutations_note.tex",
        manual_register_tex = true,

        build = "wagstaff_notes",
        bank = "wagstaff_notes",
        anim = "idle",

        -- deps = {},

        init_unlock = true,
    },

    stariliad_dataset_note_space_pirates   = {
        type = "item",

        tex = "wagstaff_mutations_note.tex",
        manual_register_tex = true,

        build = "wagstaff_notes",
        bank = "wagstaff_notes",
        anim = "idle",

        deps = { "stariliad_dataset_note_ancient_war",
            "stariliad_space_pirate_probe",
            "stariliad_space_pirate_solider_lv1",
            "stariliad_space_pirate_solider_lv2",
            "stariliad_space_pirate_solider_lv3"
        },

        init_unlock = true,
    },

    blythe_blaster                         = {
        type = "item",
        subcat = "weapon",

        bank = "blythe_blaster",
        build = "blythe_blaster",
        anim = "idle",

        finiteuses = TUNING.BLYTHE_BLASTER_USES,
        forgerepairable = { "blythe_blaster_repair_kit" },

        weapondamage = string.format("%d-%d", TUNING.BLYTHE_BEAM_BASIC_DAMAGE, TUNING.BLYTHE_SUPER_MISSILE_DAMAGE),

        deps = { "blythe_blaster_repair_kit", "blythe_blaster_upgrade_kit" },

        craftingprefab = "blythe",
    },

    stariliad_hat_green_glass_helmet       = {
        type = "item",
        subcat = "hat",

        bank = "stariliad_hat_green_glass_helmet3",
        build = "stariliad_hat_green_glass_helmet3",
        anim = "idle",

        insulator = TUNING.INSULATION_SMALL,
        insulator_type = "winter",

        waterproofer = TUNING.WATERPROOFNESS_ABSOLUTE,

        armor = TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET,
        absorb_percent = TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET_ABSORPTION,
        armor_planardefense = TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET_PLANAR_DEF,
    },

    blythe_backpack                        = {
        type = "item",
        subcat = "backpack",

        bank = "blythe_backpack",
        build = "blythe_backpack",
        anim = "idle",

        craftingprefab = "blythe",
    },

    blythe_blaster_repair_kit              = {
        type = "item",

        bank = "blythe_blaster_repair_kit",
        build = "blythe_blaster_repair_kit",
        anim = "idle",

        craftingprefab = "blythe",

        deps = { "blythe_blaster" },
    },

    blythe_blaster_upgrade_kit             = {
        type = "item",

        bank = "blythe_blaster_upgrade_kit",
        build = "blythe_blaster_upgrade_kit",
        anim = "idle",

        craftingprefab = "blythe",

        deps = { "blythe_blaster" },
    },

    blythe_unlock_skill_item_missile       = {
        type = "item",

        bank = "blythe_missile_tank",
        build = "blythe_missile_tank",
        anim = "normal",

        craftingprefab = "blythe",

        deps = { "blythe_blaster" },
    },

    blythe_unlock_skill_item_super_missile = {
        type = "item",

        bank = "blythe_missile_tank",
        build = "blythe_missile_tank",
        anim = "super",

        craftingprefab = "blythe",

        deps = { "blythe_blaster" },
    },

    stariliad_boss_guardian                = {
        type = "giant",

        bank = "beetletaur",
        build = "stariliad_boss_guardian",
        anim = "idle",
        facing = FACING_DOWN,
        scale = 1.1,
        animoffsetx = 10,

        health = TUNING.STARILIAD_BOSS_GUARDIAN_HEALTH,
        damage = function()
            local damages = {
                TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE,
                TUNING.STARILIAD_BOSS_GUARDIAN_COUNTER_DAMAGE,
                TUNING.STARILIAD_BOSS_GUARDIAN_UPPERCUT_DAMAGE,
                TUNING.STARILIAD_BOSS_GUARDIAN_LEAP_DAMAGE,
                TUNING.STARILIAD_BOSS_GUARDIAN_TAUNT_POUND_DAMAGE,
            }

            local max_damage = damages[1]
            local min_damage = damages[1]

            for _, damage in pairs(damages) do
                if damage > max_damage then
                    max_damage = damage
                end
                if damage < min_damage then
                    min_damage = damage
                end
            end

            return string.format("%d-%d", min_damage, max_damage)
        end,

        deps = { "stariliad_guardian_scales" },
        notes = { lunar_aligned = true },
    },

    stariliad_boss_gorgoroth               = {
        type = "giant",

        bank = "crick_crickantqueen",
        build = "stariliad_boss_gorgoroth",
        anim = "idle",
        overridesymbol = { "crick_headbase", "stariliad_boss_gorgoroth_head", "crick_headbase" },
        hidesymbol = { "crick_antenna", "crick_crown", "crick_eye1", "crick_eye2" },
        scale = 1.3,
        animoffsetx = 20,

        health = TUNING.STARILIAD_BOSS_GORGOROTH_HEALTH,
        damage = string.format("%d-%d", TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_DAMAGE,
            TUNING.STARILIAD_BOSS_GORGOROTH_DAMAGE),
        planardamage = TUNING.STARILIAD_BOSS_GORGOROTH_PLANAR_DAMAGE,

        sanityaura = -TUNING.SANITYAURA_HUGE,

        deps = { "stariliad_hat_gelblob" },

        notes = { shadow_aligned = true },
    },

    stariliad_guardian_scales              = {
        type = "item",

        bank = "stariliad_guardian_scales",
        build = "stariliad_guardian_scales",
        anim = "idle",

        weapondamage = TUNING.STARILIAD_GUARDIAN_SCALES_DAMAGE,

        deps = { "stariliad_boss_guardian" },
    },

    stariliad_hat_gelblob                  = {
        type = "item",
        subcat = "hat",

        bank = "stariliad_hat_gelblob",
        build = "stariliad_hat_gelblob",
        anim = "idle",

        deps = { "stariliad_boss_gorgoroth" },

        insulator = TUNING.INSULATION_LARGE,
        insulator_type = "winter",
    },

    stariliad_falling_star                 = {
        type = "food",

        bank = "stariliad_falling_star",
        build = "stariliad_falling_star",
        anim = "idle",

        stacksize = TUNING.STACK_SIZE_SMALLITEM,

        hungervalue = 1,
        healthvalue = 0,
        sanityvalue = 0,

        foodtype = FOODTYPE.GOODIES,

        deps = { "stariliad_falling_star_cooked", "stariliad_magic_crystal" }
    },

    stariliad_falling_star_cooked          = {
        type = "food",

        bank = "stariliad_falling_star",
        build = "stariliad_falling_star",
        anim = "idle_cooked",

        stacksize = TUNING.STACK_SIZE_SMALLITEM,

        hungervalue = 1,
        healthvalue = 1,
        sanityvalue = 1,

        foodtype = FOODTYPE.GOODIES,

        perishable = TUNING.PERISH_FAST,

        deps = { "stariliad_magic_crystal", "spoiled_food" }
    },

    stariliad_magic_crystal                = {
        type = "food",

        bank = "cook_pot_food",
        build = "stariliad_preparedfoods",
        anim = "idle",
        overridesymbol = { "swap_food", "stariliad_preparedfoods", "stariliad_magic_crystal" },

        stacksize = TUNING.STACK_SIZE_SMALLITEM,

        hungervalue = TUNING.CALORIES_MED,
        healthvalue = TUNING.HEALING_SMALL,
        sanityvalue = TUNING.SANITY_TINY,

        foodtype = FOODTYPE.GOODIES,

        -- deps = { "stariliad_falling_star" }
    },

    stariliad_space_pirate_probe           = {
        type = "creature",
        subcat = "drone",

        bank = "scanner",
        build = "stariliad_space_pirate_probe",
        anim = "scan_loop",
        animpercent = 0.6,
        facing = FACING_RIGHT,
        animoffsetx = 10,
        hide = { "top_light" },

        -- TODO: Add to TUNING
        health = 100,

        deps = { "stariliad_space_pirate_solider_lv1", "stariliad_space_pirate_solider_lv2", "stariliad_space_pirate_solider_lv3" },
    },

    stariliad_space_pirate_solider_lv1     = {
        type = "creature",

        bank = "antman",
        build = "stariliad_space_pirate_solider_lv1",
        anim = "idle_loop",
        animpercent = 0,
        facing = FACING_DOWN,
        animoffsety = 25,

        health = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_HEALTH,
        damage = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_ATTACK_DAMAGE,

        deps = { "stariliad_hulk_bomb_placed" },
    },

    stariliad_space_pirate_solider_lv2     = {
        type = "creature",

        bank = "antman",
        build = "stariliad_space_pirate_solider_lv2",
        anim = "idle_loop",
        animpercent = 0,
        facing = FACING_DOWN,
        animoffsety = 25,

        health = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_HEALTH,
        damage = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV2_ATTACK_DAMAGE,

        deps = {},
    },

    stariliad_space_pirate_solider_lv3     = {
        type = "creature",

        bank = "antman",
        build = "stariliad_space_pirate_solider_lv3",
        anim = "idle_loop",
        animpercent = 0,
        facing = FACING_DOWN,
        animoffsety = 25,

        health = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_HEALTH,
        damage = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV3_ATTACK_DAMAGE,

        deps = {},
    },

    stariliad_hulk_bomb_placed             = {
        type = "thing",
        subcat = "trap",
        manual_register_tex = true,

        bank = "metal_hulk_mine",
        build = "metal_hulk_bomb",
        anim = "green_loop",
        animpercent = 0.99,

        damage = TUNING.STARILIAD_SPACE_PIRATE_SOLIDER_LV1_MINE_DAMAGE,
    },

    stariliad_icecano                      = {
        type = "thing",

        bank = "volcano",
        build = "stariliad_icecano2",
        anim = "active_idle",
        scale = 3,
        animoffsetx = 125,
        animoffsety = -40,

        animoffsetbgx = 200,
        animoffsetbgy = 200,

        deps = { "stariliad_ice_meteor" },
    },

    stariliad_ice_meteor                   = {
        type = "thing",

        bank = "stariliad_lava_meteor",
        build = "stariliad_ice_meteor",
        anim = "egg_idle",
        animoffsety = -8,

        damage = TUNING.STARILIAD_ICE_METEOR_DAMAGE,
        burnable = true,

        deps = { "stariliad_ice_crystal" },
    },

    stariliad_ice_crystal                  = {
        type = "item",

        bank = "stariliad_ice_crystal",
        build = "stariliad_ice_crystal",
        anim = "idle",

        perishable = TUNING.PERISH_FAST,

        stacksize = TUNING.STACK_SIZE_SMALLITEM,

    },


}

for name, data in pairs(STARILIAD_SCRAPBOOK_DATA) do
    for k, v in pairs(data) do
        if type(v) == "function" then
            data[k] = v()
        end
    end

    if data.name == nil then
        data.name = name
    end

    if data.prefab == nil then
        data.prefab = name
    end

    if data.tex == nil then
        data.tex = name .. ".tex"
    end

    if not data.manual_register_tex then
        if data.type == "item" or data.type == "food" then
            RegisterInventoryItemAtlas("images/inventoryimages/" .. name .. ".xml", name .. ".tex")
        end
    end

    scrapbookdata[name] = data
end

RegisterScrapbookIconAtlas("images/ui/scrapbook_images/blythe.xml", "blythe.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_boss_guardian.xml", "stariliad_boss_guardian.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_boss_gorgoroth.xml", "stariliad_boss_gorgoroth.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_space_pirate_solider_lv1.xml",
    "stariliad_space_pirate_solider_lv1.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_space_pirate_solider_lv2.xml",
    "stariliad_space_pirate_solider_lv2.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_space_pirate_solider_lv3.xml",
    "stariliad_space_pirate_solider_lv3.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_hulk_bomb_placed.xml", "stariliad_hulk_bomb_placed.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_space_pirate_probe.xml",
    "stariliad_space_pirate_probe.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_ice_meteor.xml", "stariliad_ice_meteor.tex")
RegisterScrapbookIconAtlas("images/ui/scrapbook_images/stariliad_icecano.xml", "stariliad_icecano.tex")

-- AUTOGEN
-- local scrapbookprefabs = require("scrapbook_prefabs")
-- scrapbookprefabs = {
--     "blythe_blaster",
--     "blythe_backpack",
--     "blythe_blaster_repair_kit",
--     "blythe_blaster_upgrade_kit",
--     "blythe_unlock_skill_item_missile",
--     "blythe_unlock_skill_item_super_missile",
--     "stariliad_boss_guardian",
--     "stariliad_boss_gorgoroth",
--     "stariliad_guardian_scales",
--     "stariliad_hat_gelblob",
--     "stariliad_falling_star",
--     "stariliad_falling_star_cooked",
--     "stariliad_magic_crystal",
-- }

-- local scrapbookprefabs = require("scrapbook_prefabs") dumptable(scrapbookprefabs)
-- require("debugcommands") d_createscrapbookdata()




AddPlayerPostInit(function(inst)
    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(1, function()
            if inst == ThePlayer then
                for name, data in pairs(STARILIAD_SCRAPBOOK_DATA) do
                    if data.init_unlock then
                        print(inst, "init unlock scrapbook data:", data.prefab)
                        TheScrapbookPartitions:UpdateStorageData(hash(data.prefab), 0xFFFFFFFF)
                    end
                end
            end
        end)


        return
    end
end)
