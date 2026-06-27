GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("main/tiles")

local StaticLayout = require("map/static_layout")
local Layouts = require("map/layouts").Layouts
local Tasks = require("map/tasks")
-- local maze_rooms = require("map/maze_layouts")

-- archive_orchestrina_main
-- archive_centipede_husk
-- for dir, v in pairs(maze_rooms.AllLayouts.archive_keyroom) do
-- 	print("Remove husk:", v.layout.archive_centipede_husk)
-- 	v.layout.archive_centipede_husk = nil
-- end

--adding new keys and locks
local locks = 1
for _, v in pairs(LOCKS) do
	if v >= locks then
		locks = v
	end
end
locks = locks + 1

local keys = 1
for _, v in pairs(KEYS) do
	if v >= keys then
		keys = v
	end
end
keys = keys + 1

local function AddLock(name)
	LOCKS[name] = locks
	locks = locks + 1

	print(string.format("New LOCKS[%s] = %d", name, LOCKS[name]))
end

local function AddKey(name)
	KEYS[name] = keys
	keys = keys + 1

	print(string.format("New KEYS[%s] = %d", name, KEYS[name]))
end

local function RegisterKeyForLock(lock_name, key_name)
	if type(key_name) == "table" then
		for _, v in pairs(key_name) do
			RegisterKeyForLock(lock_name, v)
		end
		return
	end

	if LOCKS_KEYS[LOCKS[lock_name]] == nil then
		LOCKS_KEYS[LOCKS[lock_name]] = {}
	end
	table.insert(LOCKS_KEYS[LOCKS[lock_name]], KEYS[key_name])

	print(string.format("New pairs: LOCKS[%s] <-> KEYS[%s]", lock_name, key_name))
end

-- Extra locks
AddLock("STARILIAD_ICE_CAVE_ENTRANCE")

-- Extra keys
AddKey("STARILIAD_ICE_CAVE_ENTRANCE")

-- Extra lock-key pairs
RegisterKeyForLock("STARILIAD_ICE_CAVE_ENTRANCE", "STARILIAD_ICE_CAVE_ENTRANCE")

local function MyAddStaticLayout(name, path, additional_props)
	Layouts[name] = StaticLayout.Get(path, additional_props)

	Layouts[name].ground_types[WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB] = WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB
	Layouts[name].ground_types[17] = WORLD_TILES.MARSH

	return Layouts[name]
end

Layouts["stariliad_alien_ruin_missile"] = StaticLayout.Get("map/static_layouts/stariliad_alien_ruin_circle_pillar2", {
	areas = {
		middle_entity = function()
			return { "stariliad_alien_statue_missile" }
		end,
	},
})
-- Layouts["stariliad_alien_ruin_missile"].ground_types[62] = WORLD_TILES.STARILIAD_ALIEN_RUINS_SLAB
MyAddStaticLayout("stariliad_gorgoroth_hideout", "map/static_layouts/stariliad_gorgoroth_hideout")
MyAddStaticLayout("stariliad_bonus_grass_missile", "map/static_layouts/stariliad_bonus_grass_missile")
MyAddStaticLayout("stariliad_bonus_sanityrock_missile", "map/static_layouts/stariliad_bonus_sanityrock_missile")
MyAddStaticLayout("stariliad_bonus_pigguard_missile", "map/static_layouts/stariliad_bonus_pigguard_missile")
MyAddStaticLayout("stariliad_bonus_tallbird_missile", "map/static_layouts/stariliad_bonus_tallbird_missile")
MyAddStaticLayout("stariliad_bonus_tentacle_missile", "map/static_layouts/stariliad_bonus_tentacle_missile")
MyAddStaticLayout("stariliad_bonus_bishop_missile", "map/static_layouts/stariliad_bonus_bishop_missile")
MyAddStaticLayout("stariliad_bonus_leif_missile", "map/static_layouts/stariliad_bonus_leif_missile")
MyAddStaticLayout("stariliad_bonus_spiderden_missile", "map/static_layouts/stariliad_bonus_spiderden_missile")
MyAddStaticLayout("stariliad_event_joust", "map/static_layouts/stariliad_event_joust", {
	disable_transform = true
})
MyAddStaticLayout("stariliad_spyder_hideout", "map/static_layouts/stariliad_spyder_hideout", {
	disable_transform = true
})
MyAddStaticLayout("stariliad_spyder_hideout_large", "map/static_layouts/stariliad_spyder_hideout_large", {
	disable_transform = true
})
MyAddStaticLayout("stariliad_icecano_and_entrance", "map/static_layouts/stariliad_icecano_and_entrance")
MyAddStaticLayout("stariliad_icecano_large", "map/static_layouts/stariliad_icecano_large")
-- MyAddStaticLayout("stariliad_icecano_small", "map/static_layouts/stariliad_icecano_small")
-- MyAddStaticLayout("stariliad_ice_cave_entrance", "map/static_layouts/stariliad_ice_cave_entrance")
MyAddStaticLayout("stariliad_ice_cave_exit", "map/static_layouts/stariliad_ice_cave_exit")
MyAddStaticLayout("blythe_impact_zone", "map/static_layouts/blythe_impact_zone")

-- FUNGUSMOON
-- si_layout("stariliad_chozo_statue_dodge")
MyAddStaticLayout("stariliad_chozo_statue_dodge", "map/static_layouts/stariliad_chozo_statue_dodge")
MyAddStaticLayout("stariliad_chozo_statue_scan", "map/static_layouts/stariliad_chozo_statue_scan")

MyAddStaticLayout("stariliad_chozo_statue_room_sample", "map/static_layouts/stariliad_chozo_statue_room_sample", {
	areas = {
		statue = function()
			return { "stariliad_alien_statue_wave_beam" }
		end,
		lights = function()
			return { "cavelight" }
		end,
	},
	disable_transform = true
})
Layouts.stariliad_chozo_statue_room_sample.ground_types[9] = WORLD_TILES.ARCHIVE
-- Layouts.stariliad_chozo_statue_room_sample.ground_types[9] = WORLD_TILES.SINKHOLE
Layouts.stariliad_chozo_statue_room_sample.layout.stariliad_interior_wall_archive[1].properties = {
	data = {
		wall_data = {
			{
				{ -0.5, 0, -0.5 },
				{ -0.5, 0, 4.5 },
				{ 20.5, 0, 4.5 },
				{ 20.5, 0, -0.5 }

				-- { 0,  0, 0 },
				-- { 0,  0, 4 },
				-- { 20, 0, 4 },
				-- { 20, 0, 0 }
			}, -- vertexes
			false, --loop
		},
	}
}

-- local Layouts = require("map/layouts").Layouts print(Layouts.archive_keyroom)

local keyroom_1 = require("map/static_layouts/rooms/archive_keyroom/keyroom_1")
-- data.layers[2].objects
for _, v in pairs(keyroom_1.layers) do
	if v.name == "FG_OBJECTS" then
		-- local ids_to_remove = {}
		-- for id, obj in pairs(v.objects) do
		-- 	if obj.type == "archive_centipede_husk" then
		-- 		table.insert(ids_to_remove.id)
		-- 	end
		-- end

		local i = 1
		while i <= #(v.objects) do
			if v.objects[i].type == "archive_centipede_husk" then
				print("Remove husk in keyroom_1:", v.objects[i])
				table.remove(v.objects, i)
			else
				i = i + 1
			end
		end


		local boss_data = {
			name = "",
			type = "stariliad_boss_guardian",
			shape = "rectangle",
			x = 257,
			y = 257,
			width = 0,
			height = 0,
			visible = true,
			properties = {}
		}

		table.insert(v.objects, boss_data)
		break
	end
end


-- si_layout("stariliad_chozo_statue_room_sample")

-- AddRoom("stariliad_alien_ruin_missile_room", {
-- 	colour = { r = .5, g = 1, b = .8, a = .50 },
-- 	value = WORLD_TILES.GRASS,

-- 	required_prefabs = {
-- 		"stariliad_alien_statue_missile",
-- 	},
-- 	contents = {
-- 		countstaticlayouts = {
-- 			stariliad_alien_ruin_missile = 1,
-- 		},
-- 		distributepercent = .1,
-- 		distributeprefabs =
-- 		{
-- 			fireflies = 1,
-- 			flower = 4,
-- 			beehive = 1,
-- 		},
-- 	}
-- })

-- AddRoom("StarIliad_Test_Island_Room", {
-- 	colour = { r = 0.3, g = 0.2, b = 0.1, a = 0.3 },
-- 	value = WORLD_TILES.FOREST,
-- 	--tags = {"ForceDisconnected", "RoadPoison"},
-- 	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
-- 	required_prefabs = {
-- 		-- "greenstaff",
-- 	},
-- 	contents = {
-- 		-- countstaticlayouts =
-- 		-- {
-- 		-- 	["moontrees_2"] = function(area) return 2 + math.max(1, math.floor(area / 75)) end,
-- 		-- 	["MoonTreeHiddenAxe"] = 1,
-- 		-- },
-- 		countprefabs =
-- 		{
-- 			-- greenstaff = 1,
-- 		},
-- 		distributepercent = 0.22,
-- 		distributeprefabs =
-- 		{
-- 			grass = 0.3,
-- 			sapling = 0.3,
-- 		},
-- 	},
-- })

-- AddRoom("StarIliad_Test_Water_Area_Room", {
-- 	colour = { r = .5, g = 0.6, b = .080, a = .10 },
-- 	value = WORLD_TILES.FOREST,
-- 	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
-- 	required_prefabs = {
-- 		-- "greenstaff",
-- 		-- "goldenaxe",
-- 	},
-- 	contents = {
-- 		countprefabs =
-- 		{
-- 			-- greenstaff = 1,
-- 		},
-- 		distributepercent = 0.01,
-- 		distributeprefabs =
-- 		{
-- 			driftwood_log = 1,
-- 		},
-- 	}
-- })

-- AddRoom("StarIliad_Test_Water_Area_Room2", {
-- 	colour = { r = .36, g = .32, b = .38, a = .50 },
-- 	value = WORLD_TILES.OCEAN_COASTAL,
-- 	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
-- 	custom_tiles = {
-- 		GeneratorFunction = RUNCA.GeneratorFunction,
-- 		data = {
-- 			iterations = 8,
-- 			seed_mode = CA_SEED_MODE.SEED_RANDOM,
-- 			num_random_points = 2,
-- 			translate = {
-- 				{ tile = WORLD_TILES.OCEAN_COASTAL, items = { "goldenaxe", "cutgrass" }, item_count = 20 },
-- 			},
-- 		},
-- 	},
-- 	contents = {

-- 	}
-- })

AddRoom("stariliad_ice_cave_magma_exit", {
	colour = { r = .1, g = .1, b = .1, a = .50 },
	value = WORLD_TILES.STARILIAD_MAGMA,
	required_prefabs = {
		"cave_exit",
	},
	contents = {
		countstaticlayouts = {
			stariliad_ice_cave_exit = 1,
		},
		countprefabs =
		{
		},
		distributepercent = 0.2,
		distributeprefabs =
		{
			sapling = 0.2,
			flower_cave = 0.3,
			flower_cave_double = 0.1,
			flower_cave_triple = 0.05,
			fireflies = 0.01,
		},
	},
})

AddRoom("stariliad_ice_cave_magma_room", {
	colour = { r = .1, g = .1, b = .1, a = .50 },
	value = WORLD_TILES.STARILIAD_MAGMA,
	contents = {
		countprefabs =
		{
		},
		distributepercent = 0.1,
		distributeprefabs =
		{
			sapling = 0.3,
			flower_cave = 0.2,
			flower_cave_double = 0.1,
			flower_cave_triple = 0.05,
		},
	},
})

AddRoom("stariliad_ice_cave_ice_room1", {
	colour = { r = .1, g = .1, b = .1, a = .50 },
	value = WORLD_TILES.STARILIAD_ICE_GROUND,
	required_prefabs = {

	},
	contents = {
		countprefabs =
		{

		},
		distributepercent = 0.1,
		distributeprefabs =
		{
			-- grass = 0.3,
			stariliad_placeholder_rock_ice = 0.3,
		},
	},
})

AddRoom("stariliad_ice_cave_rock_room1", {
	colour = { r = .66, g = .66, b = .66, a = .50 },
	value = WORLD_TILES.ROCKY,
	tags = {},
	contents = {
		distributepercent = .1,
		distributeprefabs =
		{
			flint = 0.5,
			rock1 = 1,
			rock2 = 1,
			stariliad_placeholder_rock_ice = 0.4,
		},
	}
})

AddRoom("stariliad_ice_cave_flower_room1", {
	colour = { r = .25, g = .28, b = .25, a = .50 },
	value = WORLD_TILES.SINKHOLE,
	contents = {
		distributepercent = .2,
		distributeprefabs =
		{
			cavelight = 0.05,
			cavelight_small = 0.05,
			cavelight_tiny = 0.05,
			flower_cave = 0.5,
			flower_cave_double = 0.1,
			flower_cave_triple = 0.05,
			cave_fern = 0.5,
			fireflies = 0.01,

			red_mushroom = 0.1,
			green_mushroom = 0.1,
			blue_mushroom = 0.1,
		}
	}
})

AddRoom("stariliad_ice_cave_boss_room", {
	colour = { r = .25, g = .28, b = .25, a = .50 },
	value = WORLD_TILES.ROCKY,
	contents = {
		countprefabs =
		{
			greenstaff = 1,
		},

	}
})

-- AddRoom("stariliad_icecano_room1", {
-- 	colour = { r = .1, g = .1, b = .1, a = .50 },
-- 	value = WORLD_TILES.IMPASSABLE,
-- 	required_prefabs = {
-- 		"stariliad_icecano",
-- 	},
-- 	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
-- 	contents = {
-- 		countstaticlayouts = {
-- 			stariliad_icecano_small = 1,
-- 		},
-- 	},
-- })

-- AddRoom("stariliad_icecano_room2", {
-- 	colour = { r = .1, g = .1, b = .1, a = .50 },
-- 	value = WORLD_TILES.IMPASSABLE,
-- 	required_prefabs = {
-- 		"cave_entrance",
-- 	},
-- 	internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
-- 	contents = {
-- 		countstaticlayouts = {
-- 			stariliad_ice_cave_entrance = 1,
-- 		},
-- 	},
-- })


-- AddTask("StarIliad_Test_Island", {
-- 	locks = {},
-- 	keys_given = {},
-- 	region_id = "stariliad_island_test",
-- 	-- level_set_piece_blocker = true,
-- 	room_tags = { "RoadPoison", "not_mainland" },
-- 	room_choices =
-- 	{
-- 		["StarIliad_Test_Island_Room"] = 3,
-- 	},
-- 	room_bg = WORLD_TILES.FOREST,
-- 	background_room = "Empty_Cove",
-- 	cove_room_name = "Empty_Cove",
-- 	crosslink_factor = 1,
-- 	cove_room_chance = 1,
-- 	cove_room_max_edges = 2,
-- 	colour = { r = 0.6, g = 0.6, b = 0.0, a = 1 },
-- })

-- AddTask("StarIliad_Test_Water_Area", {
-- 	locks = {},
-- 	keys_given = {},
-- 	region_id = "stariliad_water_area_test",
-- 	level_set_piece_blocker = true,
-- 	room_tags = { "RoadPoison", "not_mainland" },
-- 	room_choices =
-- 	{
-- 		["StarIliad_Test_Water_Area_Room2"] = 3,
-- 	},
-- 	room_bg = WORLD_TILES.OCEAN_COASTAL,
-- 	background_room = "Empty_Cove",
-- 	cove_room_name = "Empty_Cove",
-- 	crosslink_factor = 1,
-- 	cove_room_chance = 1,
-- 	cove_room_max_edges = 2,
-- 	colour = { r = 0.6, g = 0.6, b = 0.0, a = 1 },
-- })

-- AddTask("stariliad_icecano_task", {
-- 	locks = {},
-- 	keys_given = {},
-- 	region_id = "stariliad_icecano_region",
-- 	level_set_piece_blocker = true,
-- 	room_tags = { "RoadPoison", "not_mainland" },
-- 	room_choices =
-- 	{
-- 		stariliad_icecano_room1 = 1,
-- 		stariliad_icecano_room2 = 1,
-- 	},
-- 	room_bg = WORLD_TILES.OCEAN_COASTAL,
-- 	background_room = "Empty_Cove",
-- 	cove_room_name = "Empty_Cove",
-- 	-- crosslink_factor = 1,
-- 	-- cove_room_chance = 1,
-- 	-- cove_room_max_edges = 2,
-- 	colour = { r = 0.6, g = 0.6, b = 0.0, a = 1 },
-- })

AddTask("stariliad_ice_cave_start", {
	locks = {},
	keys_given = { KEYS.TIER1 },
	region_id = "stariliad_ice_cave",
	room_choices = {
		stariliad_ice_cave_magma_exit = 1,
		stariliad_ice_cave_magma_room = 2,
	},
	entrance_room = "Empty_Cove",
	room_bg = WORLD_TILES.STARILIAD_MAGMA,
	colour = { r = .1, g = .1, b = .1, a = .50 },
})

AddTask("stariliad_ice_cave_ice_ground", {
	locks = { LOCKS.TIER1 },
	keys_given = { KEYS.TIER2 },
	region_id = "stariliad_ice_cave",
	room_choices = {
		stariliad_ice_cave_ice_room1 = 5,
	},
	room_bg = WORLD_TILES.STARILIAD_ICE_GROUND,
	colour = { r = .1, g = .1, b = .1, a = .50 },
})

AddTask("stariliad_ice_cave_green_land", {
	locks = { LOCKS.TIER2 },
	keys_given = { KEYS.TIER3 },
	region_id = "stariliad_ice_cave",
	room_choices = {
		stariliad_ice_cave_rock_room1 = 2,
		stariliad_ice_cave_flower_room1 = 1,
	},
	room_bg = WORLD_TILES.STARILIAD_ICE_GROUND,
	colour = { r = .1, g = .1, b = .1, a = .50 },
})

AddTask("stariliad_ice_cave_boss_separate", {
	locks = { LOCKS.TIER3 },
	keys_given = { KEYS.TIER4 },
	region_id = "stariliad_ice_cave",
	room_choices = {
		Empty_Cove = 5,
	},
	entrance_room = "Empty_Cove",
	room_bg = WORLD_TILES.IMPASSABLE,
	colour = { r = .1, g = .1, b = .1, a = .50 },
})

AddTask("stariliad_ice_cave_boss_area", {
	-- locks = { LOCKS.TIER4 },
	locks = { LOCKS.TIER3 },
	keys_given = {},
	region_id = "stariliad_ice_cave",
	room_choices = {
		stariliad_ice_cave_boss_room = 1,
	},
	entrance_room = "Empty_Cove",
	background_room = "Empty_Cove",
	room_bg = WORLD_TILES.STARILIAD_MAGMA,
	colour = { r = .1, g = .1, b = .1, a = .50 },
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

	local tasks_optional = {
		"Befriend the pigs",
		"Kill the spiders",
		"Killer bees!",
		"Make a Beehat",
		"The hunters",
		"Magic meadow",
		"Frogs and bugs",
		"Mole Colony Deciduous",
		"Mole Colony Rocks",
		"MooseBreedingTask",
	}

	local tasks_except_begin = {
		-- "Make a pick",
		-- "Dig that rock",
		"Great Plains",
		"Squeltch",
		"Beeeees!",
		"Speak to the king",
		"Forest hunters",
		"Badlands",
		"For a nice walk",
		"Lightning Bluff",
	}
	tasks_except_begin = ArrayUnion(tasks_except_begin, tasks_optional)


	taskset.set_pieces["stariliad_alien_ruin_missile"] = { count = 1, tasks = { "Dig that rock", } }
	taskset.set_pieces["stariliad_bonus_grass_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_sanityrock_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_pigguard_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_tallbird_missile"] = {
		count = 1,
		tasks = {
			-- "Dig that rock",
			"Badlands",
			"Lightning Bluff",
		}
	}
	taskset.set_pieces["stariliad_bonus_tentacle_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_bishop_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_leif_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_bonus_spiderden_missile"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_event_joust"] = { count = 1, tasks = tasks_except_begin }
	taskset.set_pieces["stariliad_chozo_statue_scan"] = { count = 1, tasks = { "Forest hunters", } }
	taskset.set_pieces["blythe_impact_zone"] = {
		count = 1,
		tasks = {
			"Make a pick",
			"Dig that rock",
			"Great Plains",
			"Squeltch",
			"Beeeees!",
			"Speak to the king",
			"Forest hunters",
			-- "Badlands",
			"For a nice walk",
			"Lightning Bluff",
		}
	}



	taskset.ocean_prefill_setpieces["stariliad_icecano_large"] = { count = 1 }
	-- taskset.ocean_prefill_setpieces["stariliad_icecano_and_entrance"] = { count = 1 }


	table.insert(taskset.required_prefabs, "stariliad_alien_statue_missile")
	table.insert(taskset.required_prefabs, "stariliad_event_joust")
	table.insert(taskset.required_prefabs, "stariliad_alien_statue_scan")
	table.insert(taskset.required_prefabs, "stariliad_icecano")
	table.insert(taskset.required_prefabs, "blythe_ship")

	-- table.insert(taskset.tasks, "StarIliad_Test_Island")
	-- table.insert(taskset.tasks, "StarIliad_Test_Water_Area")

	-- table.insert(taskset.tasks, "stariliad_icecano_task")
end)

AddTaskSetPreInit("cave_default", function(taskset)
	assert(taskset.set_pieces ~= nil)
	assert(taskset.required_prefabs ~= nil)

	-- MoonCaveForest

	taskset.set_pieces["stariliad_gorgoroth_hideout"] = { count = 1, tasks = { "BigBatCave", } }
	taskset.set_pieces["stariliad_chozo_statue_dodge"] = { count = 1, tasks = { "MoonCaveForest", } }

	table.insert(taskset.required_prefabs, "stariliad_boss_gorgoroth")
	table.insert(taskset.required_prefabs, "stariliad_alien_statue_dodge")

	-- table.insert(taskset.tasks, "StarIliad_Test_Island")
	-- table.insert(taskset.tasks, "StarIliad_Test_Water_Area")

	table.insert(taskset.tasks, "stariliad_ice_cave_start")
	table.insert(taskset.tasks, "stariliad_ice_cave_ice_ground")
	table.insert(taskset.tasks, "stariliad_ice_cave_green_land")
	-- table.insert(taskset.tasks, "stariliad_ice_cave_boss_separate")
	table.insert(taskset.tasks, "stariliad_ice_cave_boss_area")
end)



-- AddTaskPreInit("Dig that rock", function(task)
-- 	task.room_choices["stariliad_alien_ruin_missile_room"] = 1
-- end)


local function LevelPreInit(level)
	if level.location == "forest" then

	end

	if level.location == "cave" then
		level.overrides.keep_disconnected_tiles = true
	end
end

AddLevelPreInitAny(LevelPreInit)
