-- DeconstructRecipe()

local function MyAddRecipe2(name, ingredients, tech, config, filters, ...)
    -- For quick search build image
    if config then
        if config.atlas == nil and config.image == nil then
            config.image = name .. ".tex"
            config.atlas = "images/inventoryimages/" .. name .. ".xml"
        end
    end

    return AddRecipe2(name, ingredients, tech, config, filters, ...)
end


local function AddRecipeWithManyIngredients(name, list_ingredients, tech, config, filters, ...)
    if not config then
        config = {}
    end

    config.product = name

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
