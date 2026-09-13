AddIngredientValues({ "stariliad_falling_star" }, { magic = 1 }, true)

AddIngredientValues({ "stariliad_curse_toad_parasite_infect" }, { meat = 0.5, monster = 1, egg = 0.5 }, true)

local foods = require("stariliad_preparedfoods")
for k, recipe in pairs(foods) do
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)

    if recipe.card_def then
        AddRecipeCard("cookpot", recipe)
    end
end
