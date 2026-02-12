return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 3,
  height = 3,
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
      width = 3,
      height = 3,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 7, 0,
        7, 7, 7,
        0, 7, 0
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
          x = 96,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "leif",
          shape = "rectangle",
          x = 109,
          y = 125,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 113,
          y = 63,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 51,
          y = 83,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 54,
          y = 122,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 92,
          y = 153,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 136,
          y = 151,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pigman",
          shape = "rectangle",
          x = 151,
          y = 97,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_tall",
          shape = "rectangle",
          x = 85,
          y = 108,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_tall",
          shape = "rectangle",
          x = 106,
          y = 105,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_tall",
          shape = "rectangle",
          x = 83,
          y = 84,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_tall",
          shape = "rectangle",
          x = 107,
          y = 83,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
