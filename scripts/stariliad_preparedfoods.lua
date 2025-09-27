local function GetNum(params, ...)
    local result = 0

    for _, val in pairs({ ... }) do
        if type(val) == "string" then
            result = result + (params[val] or 0)
        elseif type(val) == "table" then
            for _, v in pairs(val) do
                result = result + (params[v] or 0)
            end
        end
    end

    return result
end

-- For foods can't be cooked,but can get by other ways
local function CantCookTestFn()
    return false
end

local function CookTime(t)
    -- Quick cook debug
    -- return 2 * FRAMES / 20.0

    return t / 20.0
end


local foods = {
    stariliad_magic_crystal =
    {
        test = function(cooker, names, tags)
            return GetNum(names, "stariliad_falling_star", "stariliad_falling_star_cooked") >= 4
        end,
        priority = 0,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_MED,
        -- perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = CookTime(5),
        potlevel = "high",
        -- floater = { "small", nil, nil },
        sinks = true,
        card_def = { ingredients = { { "stariliad_falling_star", 4 }, } },
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_HUNGER_UPGRADE,
        oneatenfn = function(inst, eater)
            if eater.components.blythe_status_bonus then
                local addition = math.min(TUNING.BLYTHE_HUNGER_UPGRADE,
                    TUNING.BLYTHE_HUNGER_THRESHOLD - eater.components.hunger.max)
                if addition > 0 then
                    eater.components.blythe_status_bonus:AddBonus("hunger", addition)
                end
            end
        end,
    },
}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.cookbook_category = "cookpot"
    v.overridebuild = "stariliad_preparedfoods"
    -- v.cookbook_atlas = "images/inventoryimages/"..k..".xml"
    v.cookbook_atlas = "images/ui/cookbook_images/" .. k .. ".xml"
end

return foods
