GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("main/tiles")

local StaticLayout = require("map/static_layout")
local Layouts = require("map/layouts").Layouts
local Tasks = require("map/tasks")


local function MyAddStaticLayout(name, path)
	Layouts[name] = StaticLayout.Get(path)

	-- Layouts[name].ground_types[WORLD_TILES.ICEY2_JUNGLE] = WORLD_TILES.ICEY2_JUNGLE

	return Layouts[name]
end

AddTaskSetPreInit("default", function(taskset)
	assert(taskset.set_pieces ~= nil)
	assert(taskset.required_prefabs ~= nil)

	local tasks_must_contain = {
		"Make a pick",
		"Dig that rock",
		"Great Plains",
		"Squeltch",
		"Beeeees!",
		"Speak to the king",
		"Forest hunters",
		"Badlands",
		"For a nice walk",
		"Lightning Bluff",
	}

	-- taskset.set_pieces["static_layout_name"] = { count = 8, tasks = { "Dig that rock", } }
	-- table.insert(taskset.required_prefabs, "stariliad_alien_statue_missile")
end)

-- TODO: Add alien statue layouts to classic task set
-- AddTaskSetPreInit("classic", function(taskset)
-- 	assert(taskset.set_pieces ~= nil)

-- 	local tasks_must_contain = {
-- 		"Make a pick",
-- 		"Dig that rock",
-- 		"Great Plains",
-- 		"Squeltch",
-- 		"Beeeees!",
-- 		"Speak to the king classic",
-- 		"Forest hunters",
-- 		"For a nice walk",
-- 	}

-- 	-- taskset.set_pieces["static_layout_name"] = { count = 8, tasks = { "Dig that rock", } }
-- end)


-- MyAddStaticLayout("icey1_graveyard", "layouts/icey1_graveyard")
