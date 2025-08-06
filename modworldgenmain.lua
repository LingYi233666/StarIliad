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

AddRoom("StarIliad_Test_Island_Room", {
	colour = { r = 0.3, g = 0.2, b = 0.1, a = 0.3 },
	value = WORLD_TILES.FOREST,
	--tags = {"ForceDisconnected", "RoadPoison"},
	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	required_prefabs = {
		-- "greenstaff",
	},
	contents = {
		-- countstaticlayouts =
		-- {
		-- 	["moontrees_2"] = function(area) return 2 + math.max(1, math.floor(area / 75)) end,
		-- 	["MoonTreeHiddenAxe"] = 1,
		-- },
		countprefabs =
		{
			-- greenstaff = 1,
		},
		distributepercent = 0.22,
		distributeprefabs =
		{
			grass = 0.3,
			sapling = 0.3,
		},
	},
})

AddRoom("StarIliad_Test_Water_Area_Room", {
	colour = { r = .5, g = 0.6, b = .080, a = .10 },
	value = WORLD_TILES.FOREST,
	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	required_prefabs = {
		-- "greenstaff",
		-- "goldenaxe",
	},
	contents = {
		countprefabs =
		{
			-- greenstaff = 1,
		},
		distributepercent = 0.01,
		distributeprefabs =
		{
			driftwood_log = 1,
		},
	}
})

AddTask("StarIliad_Test_Island", {
	locks = {},
	keys_given = {},
	region_id = "stariliad_island_test",
	-- level_set_piece_blocker = true,
	room_tags = { "RoadPoison", "not_mainland" },
	room_choices =
	{
		["StarIliad_Test_Island_Room"] = 3,
	},
	room_bg = WORLD_TILES.FOREST,
	background_room = "Empty_Cove",
	cove_room_name = "Empty_Cove",
	crosslink_factor = 1,
	cove_room_chance = 1,
	cove_room_max_edges = 2,
	colour = { r = 0.6, g = 0.6, b = 0.0, a = 1 },
})

AddTask("StarIliad_Test_Water_Area", {
	locks = {},
	keys_given = {},
	region_id = "stariliad_water_area_test",
	level_set_piece_blocker = true,
	room_tags = { "RoadPoison", "not_mainland" },
	room_choices =
	{
		["StarIliad_Test_Water_Area_Room"] = 3,
	},
	room_bg = WORLD_TILES.OCEAN_COASTAL,
	background_room = "Empty_Cove",
	cove_room_name = "Empty_Cove",
	crosslink_factor = 1,
	cove_room_chance = 1,
	cove_room_max_edges = 2,
	colour = { r = 0.6, g = 0.6, b = 0.0, a = 1 },
})

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

	table.insert(taskset.tasks, "StarIliad_Test_Island")
	-- table.insert(taskset.tasks, "StarIliad_Test_Water_Area")
end)

AddTaskPreInit("Dig that rock", function(task)
	task.room_choices["stariliad_alien_ruin_missile_room"] = 1
end)
