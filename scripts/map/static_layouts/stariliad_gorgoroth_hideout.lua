return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 10,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../../Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../../Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 25, 25, 25, 28, 28, 25, 25, 25, 0,
        0, 25, 25, 25, 28, 28, 25, 25, 25, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 25, 25, 25, 25, 25, 25, 25, 25, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "pillar_ruins",
          shape = "rectangle",
          x = 96,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pillar_ruins",
          shape = "rectangle",
          x = 544,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pillar_ruins",
          shape = "rectangle",
          x = 544,
          y = 544,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pillar_ruins",
          shape = "rectangle",
          x = 96,
          y = 544,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "stariliad_boss_gorgoroth_spawner",
          shape = "rectangle",
          x = 320,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
