return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 1,
  height = 1,
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
      width = 1,
      height = 1,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        3
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
          type = "tallbirdnest",
          shape = "rectangle",
          x = 32,
          y = 33,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.is_stariliad_missile"] = "true"
          }
        },
        {
          name = "",
          type = "rock1",
          shape = "rectangle",
          x = 4,
          y = 56,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rock_flintless",
          shape = "rectangle",
          x = 59,
          y = 59,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rock1",
          shape = "rectangle",
          x = 35,
          y = 1,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
