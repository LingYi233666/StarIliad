PrefabFiles = {
    "blythe",      --人物代码文件
    "blythe_none", --人物皮肤
}
---对比老版本 主要是增加了names图片 人物检查图标 还有人物的手臂修复（增加了上臂）
--人物动画里面有个SWAP_ICON 里面的图片是在检查时候人物头像那里显示用的


----2019.05.08 修复了 人物大图显示错误和检查图标显示错误
--2020.05.31  新加人物选人界面的属性显示信息
Assets = {
    Asset("IMAGE", "images/saveslot_portraits/blythe.tex"), --存档图片
    Asset("ATLAS", "images/saveslot_portraits/blythe.xml"),

    -- Asset("IMAGE", "images/selectscreen_portraits/blythe.tex"), --单机选人界面
    -- Asset("ATLAS", "images/selectscreen_portraits/blythe.xml"),

    -- Asset("IMAGE", "images/selectscreen_portraits/blythe_silho.tex"), --单机未解锁界面
    -- Asset("ATLAS", "images/selectscreen_portraits/blythe_silho.xml"),

    Asset("IMAGE", "bigportraits/blythe.tex"), --人物大图（方形的那个）
    Asset("ATLAS", "bigportraits/blythe.xml"),

    Asset("IMAGE", "images/map_icons/blythe.tex"), --小地图
    Asset("ATLAS", "images/map_icons/blythe.xml"),

    Asset("IMAGE", "images/avatars/avatar_blythe.tex"), --tab键人物列表显示的头像
    Asset("ATLAS", "images/avatars/avatar_blythe.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_blythe.tex"), --tab键人物列表显示的头像（死亡）
    Asset("ATLAS", "images/avatars/avatar_ghost_blythe.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_blythe.tex"), --人物检查按钮的图片
    Asset("ATLAS", "images/avatars/self_inspect_blythe.xml"),

    Asset("IMAGE", "images/names_blythe.tex"), --人物名字
    Asset("ATLAS", "images/names_blythe.xml"),

    Asset("IMAGE", "bigportraits/blythe_none.tex"), --人物大图（椭圆的那个）
    Asset("ATLAS", "bigportraits/blythe_none.xml"),

    --[[---注意事项
1、目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
2、官方人物目前的图片跟名字是分开的
3、names_blythe 和 blythe_none 这两个文件需要特别注意！！！
这两文件每一次重新转换之后！需要到对应的xml里面改对应的名字 否则游戏里面无法显示
具体为：
降names_esctemplatxml 里面的 Element name="blythe.tex" （也就是去掉names——）
将blythe_none.xml 里面的 Element name="blythe_none_oval" 也就是后面要加  _oval
（注意看修改的名字！不是两个都需要修改）
	]]
}

GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})

PREFAB_SKINS["blythe"] = { --修复人物大图显示
    "blythe_none",
}

AddMinimapAtlas("images/map_icons/blythe.xml") --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("blythe", "FEMALE")

local import_list = {
    "tuning",
    "language_chs"
}

for _, v in pairs(import_list) do
    modimport("main/" .. v)
end
