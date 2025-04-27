local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

	Asset("IMAGE", "images/saveslot_portraits/blythe.tex"), --存档图片
	Asset("ATLAS", "images/saveslot_portraits/blythe.xml"),

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

	---对比老版本 主要是增加了names图片 人物检查图标 还有人物的手臂修复（增加了上臂）
	--人物动画里面有个SWAP_ICON 里面的图片是在检查时候人物头像那里显示用的
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
local prefabs = {}

-- 初始物品
local start_inv = {
	"blythe_blaster",
}

local function OnBecomeXParasite(inst, data)
	local r, g, b, a = 1, 0, 0, 1
	inst.AnimState:SetSymbolMultColour("ghost_body", r, g, b, a)
	inst.AnimState:SetSymbolMultColour("ghost_FX", r, g, b, a)
end

local function OnCollide(inst, other)
	if inst.components.blythe_skill_speed_burst
		and inst.components.blythe_skill_speed_burst:IsEnabled()
		and inst.components.blythe_skill_speed_burst:IsInSpeedBurst()
		and inst.components.blythe_skill_speed_burst:CanCollide(other) then
		inst.components.blythe_skill_speed_burst:OnPhysicsCollision(other)
	end
end

--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon("blythe.tex")

	inst:AddTag("blythe")
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "wendy"

	inst.Physics:SetCollisionCallback(OnCollide)


	inst:AddComponent("stariliad_spdamage_force")

	inst:AddComponent("blythe_skill_speed_burst")
	inst.components.blythe_skill_speed_burst:Enable(true)

	--最喜欢的食物
	-- inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)

	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.BLYTHE_HEALTH)
	inst.components.hunger:SetMax(TUNING.BLYTHE_HUNGER)
	inst.components.sanity:SetMax(TUNING.BLYTHE_SANITY)

	inst:ListenForEvent("ms_becameghost", OnBecomeXParasite)
end

return MakePlayerCharacter("blythe", prefabs, assets, common_postinit, master_postinit, start_inv)
