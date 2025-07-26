------------------------------Tiles---------------------------------
local GROUND_OCEAN_COLOR = -- Color for blending to the land ground tiles
{
    primary_color = { 0, 0, 0, 25 },
    secondary_color = { 0, 20, 33, 0 },
    secondary_color_dusk = { 0, 20, 33, 80 },
    minimap_color = { 23, 51, 62, 102 },
}

local function MyAddTile(tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
    if WORLD_TILES[tile_name] == nil then
        AddTile(tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
    end
end

-- ground_ruins_slab.tex
-- local old_data = {
--     { GROUND.PIGRUINS,
--         {
--             name = "blocky",
--             noise_texture = "levels/textures/interiors/ground_ruins_slab.tex",
--             runsound = "run_dirt",
--             walksound = "walk_dirt",
--             snowsound = "run_ice",
--             mudsound = "run_mud"
--         } },

--     { GROUND.PIGRUINS_NOCANOPY,
--         {
--             name = "blocky",
--             noise_texture = "levels/textures/interiors/ground_ruins_slab.tex",
--             runsound = "run_dirt",
--             walksound = "walk_dirt",
--             snowsound = "run_ice",
--             mudsound = "run_mud"
--         }
--     },
-- }

MyAddTile("STARILIAD_ALIEN_RUINS_SLAB",
    "LAND",
    {
        ground_name = "StarIliad Alien Ruins Slab",
    },
    {
        name = "blocky",
        noise_texture = "ground_ruins_slab",
        runsound = "dontstarve/movement/run_dirt",
        walksound = "dontstarve/movement/walk_dirt",
        snowsound = "dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        colors = GROUND_OCEAN_COLOR,
    },
    {
        name = "map_edge",
        noise_texture = "mini_ruins_slab",
    }
)
