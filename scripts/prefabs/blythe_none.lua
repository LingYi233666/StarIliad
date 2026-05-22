local base_prefab = "blythe"

local skin_prefabs = {
	CreatePrefabSkin("blythe_none",
		{
			assets = {
				Asset("ANIM", "anim/blythe.zip"),
				Asset("ANIM", "anim/ghost_blythe_build.zip"),
			},
			skins = {
				normal_skin = "blythe",
				ghost_skin = "ghost_blythe_build",
			},

			base_prefab = base_prefab,
			build_name_override = "blythe",

			type = "base",
			rarity = "Character",

			skin_tags = { "BASE", "BLYTHE", "CHARACTER" },
		}
	),

	CreatePrefabSkin("ms_blythe_avgn",
		{
			assets = {
				Asset("ANIM", "anim/ms_blythe_avgn.zip"),
				Asset("ANIM", "anim/ghost_blythe_build.zip"),
			},
			skins = {
				normal_skin = "ms_blythe_avgn",
				ghost_skin = "ghost_blythe_build",
			},

			base_prefab = base_prefab,
			build_name_override = "ms_blythe_avgn",

			type = "base",
			rarity = "ModMade",

			skin_tags = { "BASE", "BLYTHE", "CHARACTER" },
		}
	),
}

return unpack(skin_prefabs)
