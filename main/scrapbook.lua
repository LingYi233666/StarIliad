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

    blythe_blaster = {
        type = "item",
        subcat = "weapon",

        bank = "blythe_blaster",
        build = "blythe_blaster",
        anim = "idle",

        forgerepairable = { "blythe_blaster_repair_kit" },

        -- deps = { "twigs", "flint" },

        craftingprefab = "blythe",
    },

    blythe_backpack = {
        type = "item",
        subcat = "backpack",

        bank = "blythe_backpack",
        build = "blythe_backpack",
        anim = "idle",

        craftingprefab = "blythe",
    },

    blythe_blaster_repair_kit = {
        type = "item",

        bank = "blythe_blaster_repair_kit",
        build = "blythe_blaster_repair_kit",
        anim = "idle",

        craftingprefab = "blythe",
    },

}


for name, data in pairs(STARILIAD_SCRAPBOOK_DATA) do
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
