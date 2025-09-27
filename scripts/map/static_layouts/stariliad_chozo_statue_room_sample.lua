return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 5,
  height = 5,
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
      width = 5,
      height = 5,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        9, 9, 9, 9, 9,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0
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
          type = "statue",
          shape = "rectangle",
          x = 272,
          y = 166,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.savedrotation.rotation"] = "180"
          }
        },
        {
          name = "",
          type = "stariliad_interior_wall_archive",
          shape = "rectangle",
          x = 0,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lights",
          shape = "rectangle",
          x = 272,
          y = 166,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "stariliad_interior_camera_default",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.affect_range_x"] = "12",
            ["data.affect_range_z"] = "3",
            ["data.camera_distance"] = "18",
            ["data.limit_range_x"] = "0",
            ["data.limit_range_z"] = "0"
          }
        }
      }
    }
  }
}
