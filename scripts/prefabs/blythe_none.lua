local assets =
{
	Asset("ANIM", "anim/blythe.zip"),
	Asset("ANIM", "anim/ghost_blythe_build.zip"),
}

local skins =
{
	normal_skin = "blythe",
	ghost_skin = "ghost_blythe_build",
}

local base_prefab = "blythe"

local tags = { "BASE", "BLYTHE", "CHARACTER" }

return CreatePrefabSkin("blythe_none",
	{
		base_prefab = base_prefab,
		skins = skins,
		assets = assets,
		skin_tags = tags,

		build_name_override = "blythe",
		rarity = "Character",
	})
