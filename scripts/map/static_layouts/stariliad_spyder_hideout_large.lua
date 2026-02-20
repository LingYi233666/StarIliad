return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 13,
  height = 13,
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
      width = 13,
      height = 13,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1,
        1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1,
        1, 1, 3, 3, 3, 3, 1, 3, 3, 3, 3, 1, 1,
        1, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 1,
        1, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 1,
        1, 3, 3, 1, 1, 1, 25, 1, 1, 1, 3, 3, 1,
        1, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 1,
        1, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 1,
        1, 1, 3, 3, 3, 3, 1, 3, 3, 3, 3, 1, 1,
        1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1,
        1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
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
          type = "stariliad_boss_spyder_spawner",
          shape = "rectangle",
          x = 416,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
