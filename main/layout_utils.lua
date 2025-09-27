StarIliadLayout = {}

local function _SpawnLayout_AddFn(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list,
                                  prefab_data, rand_offset)
    local x = (points_x[current_pos_idx] - width / 2.0) * TILE_SCALE
    local y = (points_y[current_pos_idx] - height / 2.0) * TILE_SCALE

    x = math.floor(x * 100) / 100.0
    y = math.floor(y * 100) / 100.0

    if prefab_data == nil then
        prefab_data = {}
    end

    prefab_data.x = x
    prefab_data.z = y

    prefab_data.prefab = prefab

    local ent = SpawnSaveRecord(prefab_data)

    if ent then
        ent:LoadPostPass(Ents, FunctionOrValue(prefab_data.data))

        if ent.components.scenariorunner ~= nil then
            ent.components.scenariorunner:Run()
        end
    end
end

local obj_layout = require("map/object_layout")

function StarIliadLayout.Spawn(name, pos)
    local layout                = obj_layout.LayoutForDefinition(name)
    local map_width, map_height = TheWorld.Map:GetSize()

    local add_fn                = {
        fn = _SpawnLayout_AddFn,
        args = { entitiesOut = {}, width = map_width, height = map_height, rand_offset = false }
    }


    local offset = layout.ground ~= nil and math.floor(#layout.ground / 2) or 0
    -- local size   = layout.ground ~= nil and (#layout.ground * TILE_SCALE) or nil


    -- local pos  = ConsoleWorldPosition()
    local x, z = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())

    obj_layout.Place({ x - offset, z - offset }, name, add_fn, nil, TheWorld.Map)
end

-- function StarIliadLayout.Spawn(name, pos)
--     StaticLayoutPlacer.TryToPlaceStaticLayoutNear(obj_layout.LayoutForDefinition(name), pos.x, pos.z,
--         StaticLayoutPlacer.ScanForStaticLayoutPosition_Spiral,
--         StaticLayoutPlacer.TileFilter_Impassable)
-- end

GLOBAL.StarIliadLayout = StarIliadLayout
