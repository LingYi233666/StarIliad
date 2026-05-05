return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 3,
  height = 3,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {},
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
        0, 0, 0,
        0, 0, 0,
        0, 0, 0
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
          type = "cave_exit",
          shape = "rectangle",
          x = 96,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.worldmigrator.id"] = "stariliad_ice_cave",
            ["data.worldmigrator.receivedPortal"] = "stariliad_ice_cave"
          }
        }
      }
    }
  }
}
