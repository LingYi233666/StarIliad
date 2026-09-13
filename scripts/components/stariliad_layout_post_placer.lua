-- local StaticLayout = require("map/static_layout")
local obj_layout = require("map/object_layout")

-- local obj_layout = require("map/object_layout") print(obj_layout.LayoutForDefinition("stariliad_chozo_statue_room_sample"))
-- StaticLayoutPlacer.TryToPlaceStaticLayoutNear(layout, tx, ty, StaticLayoutPlacer.ScanForStaticLayoutPosition_Spiral, StaticLayoutPlacer.TileFilter_Impassable)

-- TheWorld.components.stariliad_layout_post_placer:PlaceLayout("stariliad_chozo_statue_room_sample")
-- TheWorld.components.stariliad_layout_post_placer:PlaceLayout("stariliad_chozo_statue_room_sample",TheInput:GetWorldPosition())


local StarIliadLayoutPostPlacer = Class(function(self, inst)
    self.inst = inst

    self.layouts_define = {}
    self.placed_layouts = {}

    inst:DoTaskInTime(1, function()
        self:PlaceLayoutAfterWorldGen()
    end)
end)

function StarIliadLayoutPostPlacer:AddDefine(layout_name, pos)
    self.layouts_define[layout_name] = { pos = pos }
end

function StarIliadLayoutPostPlacer:PlaceLayoutAfterWorldGen()
    print("Post place layouts...")

    for layout_name, data in pairs(self.layouts_define) do
        if self.placed_layouts[layout_name] then
            print(string.format("Skip layout %s because it has been placed", layout_name))
        else
            if self:PlaceLayout(layout_name, data.pos) then
                print("Layout placed: " .. layout_name)
                self.placed_layouts[layout_name] = true
            else
                print("Layout place failed: " .. layout_name)
            end
        end
    end
end

local function ScanForStaticLayoutPosition_BruteForceInsideMap(tx, ty, size, displacement, filterfn)
    local map_width, map_height = TheWorld.Map:GetSize()

    for px = 1, map_width, size do
        for py = 1, map_height, size do
            if px > 0 and px < map_width - size and py > 0 and py < map_height - size
                and TheWorld.Map:IsAreaTilesFiltered(px, py, size, size, filterfn) then
                return px, py
            end
        end
    end
end

local function TileFilter_ImpassableOrOcean(tileid)
    return TileGroupManager:IsImpassableTile(tileid) or TileGroupManager:IsOceanTile(tileid)
end

function StarIliadLayoutPostPlacer:PlaceLayout(layout_name, position)
    local success = false
    local x, y, z = position:Get()
    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)

    local layout = obj_layout.LayoutForDefinition(layout_name)
    if layout then
        success = StaticLayoutPlacer.TryToPlaceStaticLayoutNear(layout, tx, ty,
            StaticLayoutPlacer.ScanForStaticLayoutPosition_Spiral, TileFilter_ImpassableOrOcean)

        if success then

        else
            print("Spiral method failed for layout: " .. layout_name, ", try brute force inside map")
            success = StaticLayoutPlacer.TryToPlaceStaticLayoutNear(layout, tx, ty,
                ScanForStaticLayoutPosition_BruteForceInsideMap, TileFilter_ImpassableOrOcean)
            if not success then
                print("Brute force method failed for layout: " .. layout_name)
            end
        end
    else
        print("Layout not found: " .. layout_name)
    end

    return success
end

function StarIliadLayoutPostPlacer:OnSave()
    local data = {
        placed_layouts = {},
    }

    for id, boolean in pairs(self.placed_layouts) do
        if boolean then
            table.insert(data.placed_layouts, id)
        end
    end

    return data
end

function StarIliadLayoutPostPlacer:OnLoad(data)
    if data ~= nil then
        if data.placed_layouts ~= nil then
            for _, id in pairs(data.placed_layouts) do
                self.placed_layouts[id] = true
            end
        end
    end
end

return StarIliadLayoutPostPlacer
