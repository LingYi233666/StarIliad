------------------------------Tiles---------------------------------
local GROUND_OCEAN_COLOR = -- Color for blending to the land ground tiles
{
    primary_color = { 0, 0, 0, 25 },
    secondary_color = { 0, 20, 33, 0 },
    secondary_color_dusk = { 0, 20, 33, 80 },
    minimap_color = { 23, 51, 62, 102 },
}

-- if WORLD_TILES.ICEY2_JUNGLE == nil then
--     -- (tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
--     AddTile(
--         "ICEY2_JUNGLE",
--         "LAND",
--         {
--             ground_name = "Icey2 Jungle",
--         },
--         {
--             name = "jungle",
--             noise_texture = "Ground_noise_jungle",
--             runsound = "dontstarve/movement/run_woods",
--             walksound = "dontstarve/movement/walk_woods",
--             snowsound = "dontstarve/movement/run_snow",
--             mudsound = "dontstarve/movement/run_mud",
--             colors = GROUND_OCEAN_COLOR,
--         },
--         {
--             name = "map_edge",
--             noise_texture = "mini_jungle_noise",
--         }
--     )
-- end


---------------------------------------------------------------------
