GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("main/tiles")

local StaticLayout = require("map/static_layout")
local Layouts = require("map/layouts").Layouts
local Tasks = require("map/tasks")


local function MyAddStaticLayout(name, path)
	Layouts[name] = StaticLayout.Get(path)

	Layouts[name].ground_types[WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB] = WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB

	return Layouts[name]
end

Layouts["stariliad_alien_ruin_missile"] = StaticLayout.Get("map/static_layouts/stariliad_alien_ruin_circle_pillar", {
	areas = {
		middle_entity = function()
			return { "stariliad_alien_statue_missile" }
		end,
	},
})
Layouts["stariliad_alien_ruin_missile"].ground_types[62] = WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB

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

	-- taskset.set_pieces["stariliad_alien_ruin_missile"] = { count = 1, tasks = { "Dig that rock", } }

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

-- AddRoom("stariliad_alien_ruin_missile_room", {
-- 	colour = { r = .5, g = 0.6, b = .080, a = .10 },
-- 	value = WORLD_TILES.FOREST,
-- 	tags = { "ExitPiece", },
-- 	required_prefabs = {
-- 		"stariliad_alien_statue_missile",
-- 	},
-- 	contents = {
-- 		countstaticlayouts = {
-- 			stariliad_alien_ruin_missile = 1,
-- 		},
-- 		distributepercent = .3,
-- 		distributeprefabs =
-- 		{
-- 			fireflies = 0.2,
-- 			--evergreen = 6,
-- 			rock1 = 0.05,
-- 			grass = .05,
-- 			sapling = .8,
-- 			twiggytree = 0.8,
-- 			ground_twigs = 0.06,
-- 			--rabbithole=.05,
-- 			berrybush = .03,
-- 			berrybush_juicy = 0.015,
-- 			red_mushroom = .03,
-- 			green_mushroom = .02,
-- 			trees = { weight = 6, prefabs = { "evergreen", "evergreen_sparse" } }
-- 		},
-- 	}
-- })

AddRoom("stariliad_alien_ruin_missile_room", {
	colour = { r = .5, g = 1, b = .8, a = .50 },
	value = WORLD_TILES.GRASS,

	required_prefabs = {
		"stariliad_alien_statue_missile",
	},
	contents = {
		countstaticlayouts = {
			stariliad_alien_ruin_missile = 1,
		},
		distributepercent = .1,
		distributeprefabs =
		{
			fireflies = 1,
			flower = 4,
			beehive = 1,
		},
	}
})

AddTaskPreInit("Dig that rock", function(task)
	task.room_choices["stariliad_alien_ruin_missile_room"] = 1
end)
