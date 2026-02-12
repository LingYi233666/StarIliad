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
        6
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
          type = "blythe_unlock_skill_item_missile",
          shape = "rectangle",
          x = 32,
          y = 32,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 64,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 0,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigtorch",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "merm",
          shape = "rectangle",
          x = 25,
          y = 15,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "merm",
          shape = "rectangle",
          x = 46,
          y = 14,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "merm",
          shape = "rectangle",
          x = 16,
          y = 44,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "merm",
          shape = "rectangle",
          x = 48,
          y = 49,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
