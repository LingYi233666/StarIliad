AddIngredientValues({ "stariliad_falling_star" }, { magic = 1 }, true)


local foods = require("stariliad_preparedfoods")
for k, recipe in pairs(foods) do
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)

    if recipe.card_def then
        AddRecipeCard("cookpot", recipe)
    end
end
