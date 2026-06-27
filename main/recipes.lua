-- DeconstructRecipe()

local function MyAddRecipe2(name, ingredients, tech, config, filters, ...)
    -- For quick search build image
    if config then
        if config.atlas == nil and config.image == nil then
            local xml_path = "images/inventoryimages/" .. name .. ".xml"
            if resolvefilepath_soft(xml_path) ~= nil then
                config.image = name .. ".tex"
                config.atlas = xml_path
            else
                config.image = "stariliad_debug_inventoryimage.tex"
                config.atlas = "images/inventoryimages/stariliad_debug_inventoryimage.xml"
            end
        end
    end

    return AddRecipe2(name, ingredients, tech, config, filters, ...)
end


local function AddRecipeWithManyIngredients(name, list_ingredients, tech, config, filters, ...)
    if not config then
        config = {}
    end

    config.product = name
    if config.atlas == nil and config.image == nil then
        config.image = name .. ".tex"
        config.atlas = "images/inventoryimages/" .. name .. ".xml"
    end

    for k, ingredients in pairs(list_ingredients) do
        MyAddRecipe2(
            name .. "_plan" .. k,
            ingredients,
            tech,
            config,
            filters,
            ...
        )
    end
end


MyAddRecipe2("blythe_blaster",
    {
        Ingredient("transistor", 2),
        Ingredient("gears", 1),
        Ingredient(CHARACTER_INGREDIENT.SANITY, 10),
    },
    TECH.NONE,
    {
        builder_tag = "blythe",
    },
    { "CHARACTER", "WEAPON" }
)

MyAddRecipe2("blythe_blaster_repair_kit",
    {
        Ingredient("twigs", 2),
        Ingredient("spidergland", 1),
        Ingredient("goldnugget", 1),
    },
    TECH.NONE,
    {
        builder_tag = "blythe",
    },
    { "CHARACTER", }
)

MyAddRecipe2("blythe_blaster_upgrade_kit",
    {
        Ingredient("moonrocknugget", 2),
        Ingredient("transistor", 2),
        Ingredient("purplegem", 1),
    },
    TECH.NONE,
    {
        builder_tag = "blythe",
    },
    { "CHARACTER", }
)

-- MyAddRecipe2("blythe_unlock_skill_item_missile",
--     {
--         Ingredient("gunpowder", 1), Ingredient("redgem", 1),
--     },
--     TECH.SCIENCE_TWO,
--     {
--         builder_tag = "blythe",
--     },
--     { "CHARACTER", "WEAPON" }
-- )

-- AddRecipeWithManyIngredients("blythe_unlock_skill_item_super_missile",
--     {
--         Ingredient("gunpowder", 1), Ingredient("greengem", 1),
--     },
--     TECH.ANCIENT_FOUR,
--     {
--         builder_tag = "blythe",
--     },
--     { "CHARACTER", "WEAPON" }
-- )


AddRecipeWithManyIngredients("blythe_unlock_skill_item_missile",
    {
        { Ingredient("gunpowder", 1), Ingredient("redgem", 1), Ingredient("turf_desertdirt", 1), },
        { Ingredient("gunpowder", 1), Ingredient("redgem", 1), Ingredient("turf_monkey_ground", 1), },
        { Ingredient("gunpowder", 1), Ingredient("redgem", 1), Ingredient("turf_pebblebeach", 1), },
        { Ingredient("gunpowder", 1), Ingredient("redgem", 1), Ingredient("turf_shellbeach", 1), },
    },
    TECH.SCIENCE_TWO,
    {
        builder_tag = "blythe",
    },
    { "CHARACTER", "WEAPON" }
)

AddRecipeWithManyIngredients("blythe_unlock_skill_item_super_missile",
    {
        { Ingredient("gunpowder", 1), Ingredient("greengem", 1), Ingredient("turf_desertdirt", 1), },
        { Ingredient("gunpowder", 1), Ingredient("greengem", 1), Ingredient("turf_monkey_ground", 1), },
        { Ingredient("gunpowder", 1), Ingredient("greengem", 1), Ingredient("turf_pebblebeach", 1), },
        { Ingredient("gunpowder", 1), Ingredient("greengem", 1), Ingredient("turf_shellbeach", 1), },
    },
    TECH.ANCIENT_FOUR,
    {
        builder_tag = "blythe",
        -- nounlock = true,
    },
    { "CHARACTER", "WEAPON" }
)

MyAddRecipe2("stariliad_ice_axe",
    {
        Ingredient("twigs", 1),
        Ingredient("stariliad_ice_crystal", 1, "images/inventoryimages/stariliad_ice_crystal.xml"),
    },
    TECH.SCIENCE_ONE,
    {

    },
    { "TOOLS" }
)

MyAddRecipe2("stariliad_ice_pickaxe",
    {
        Ingredient("twigs", 2),
        Ingredient("stariliad_ice_crystal", 3, "images/inventoryimages/stariliad_ice_crystal.xml"),
    },
    TECH.SCIENCE_ONE,
    {
    },
    { "TOOLS" }
)

MyAddRecipe2("stariliad_ice_hammer",
    {
        Ingredient("twigs", 3),
        Ingredient("stariliad_ice_crystal", 2, "images/inventoryimages/stariliad_ice_crystal.xml"),
        Ingredient("cutgrass", 6),
    },
    TECH.SCIENCE_ONE,
    {
    },
    { "TOOLS" }
)

MyAddRecipe2("stariliad_ice_backpack",
    {
        Ingredient("rope", 2),
        Ingredient("stariliad_ice_crystal", 4, "images/inventoryimages/stariliad_ice_crystal.xml"),
    },
    TECH.SCIENCE_TWO,
    {
    },
    { "CLOTHING", "CONTAINERS" }
)

MyAddRecipe2("stariliad_bingbong",
    {
        Ingredient("cutgrass", 6),
        Ingredient("beefalowool", 2),
        Ingredient("silk", 2),
        Ingredient("stariliad_ice_crystal", 1, "images/inventoryimages/stariliad_ice_crystal.xml"),
    },
    TECH.MAGIC_TWO,
    {
    },
    { "CLOTHING", }
)

MyAddRecipe2("stariliad_energy_tank",
    {
        Ingredient("redgem", 1),
        Ingredient("gears", 1),
        Ingredient("transistor", 2),
    },
    TECH.SCIENCE_TWO,
    {
        builder_tag = "blythe",
    },
    { "CHARACTER", "RESTORATION" }
)
