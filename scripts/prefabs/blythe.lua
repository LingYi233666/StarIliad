local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

	Asset("ANIM", "anim/blythe_parry.zip"),
	Asset("ANIM", "anim/blythe_parry_fx.zip"),

	Asset("ANIM", "anim/blythe_speedrun.zip"),

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

local function LeftClickPicker(inst, target, pos)
	if not inst.components.playercontroller:IsEnabled()
		or pos == nil
		or target ~= nil
		or TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z) then
		return {}, true
	end

	local inst_on_ocean = inst:IsOnOcean()
	local dest_on_ocean = TheWorld.Map:IsOceanAtPoint(pos:Get())

	if inst_on_ocean == dest_on_ocean then
		return {}, true
	end

	local actions = inst.components.playeractionpicker:SortActionList({ ACTIONS.STARILIAD_OCEAN_LAND_JUMP }, pos, nil)

	return actions
end

local function PointSpecialActions(inst, pos, useitem, right)
	if not right and inst.components.playercontroller:IsEnabled() then
		return { ACTIONS.STARILIAD_OCEAN_LAND_JUMP }
	end
	return {}
end

local function WorkMultiplierFn(inst, action, target, tool, numworks, recoil)
	local new_numworks = numworks

	if (action == ACTIONS.CHOP or action == ACTIONS.MINE or action == ACTIONS.HAMMER)
		and not (tool and tool:HasTag("blythe_tool")) then
		new_numworks = new_numworks * TUNING.BLYTHE_WORKEFFECTIVENESS_MODIFIER
	end

	return new_numworks
end

local function OnToolBroken(inst, data)
	if data
		and data.tool
		and data.tool:IsValid()
		and data.tool.prefab == "blythe_blaster"
		and not IsEntityDeadOrGhost(inst, true)
		and not inst.sg:HasStateTag("dead")
		and inst.components.talker then
		inst.components.talker:Say(GetString(inst, "ANNOUNCE_BLASTER_BROKEN"))
	end
end

--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon("blythe.tex")

	inst.AnimState:AddOverrideBuild("blythe_parry_fx")
	inst.AnimState:SetSymbolLightOverride("blythe_parry_fx", 0.7)
	-- inst.AnimState:SetSymbolMultColour("blythe_parry_fx", 1, 1, 0, 1)

	inst:AddTag("blythe")

	inst:DoTaskInTime(1, function()
		if TheWorld and TheWorld.has_ocean and inst.components.playeractionpicker ~= nil then
			inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
			-- inst.components.playeractionpicker.pointspecialactionsfn = PointSpecialActions
		end
	end)
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "wendy"

	inst.Physics:SetCollisionCallback(OnCollide)

	inst.components.drownable.enabled = false

	inst:AddComponent("stariliad_ocean_land_jump")

	inst:AddComponent("blythe_missile_counter")

	inst:AddComponent("stariliad_spdamage_beam")

	inst:AddComponent("blythe_stealth_handler")

	inst:AddComponent("blythe_skiller")

	inst:AddComponent("blythe_powersuit_configure")

	inst:AddComponent("blythe_skill_speed_burst")

	inst:AddComponent("blythe_skill_dodge")

	inst:AddComponent("blythe_skill_parry")

	inst:AddComponent("blythe_skill_scan")

	inst:AddComponent("blythe_skill_stealth")


	--最喜欢的食物
	-- inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)

	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.BLYTHE_HEALTH)
	inst.components.hunger:SetMax(TUNING.BLYTHE_HUNGER)
	inst.components.sanity:SetMax(TUNING.BLYTHE_SANITY)

	-- 惧怕寒冷
	-- inst.components.temperature.inherentinsulation = -TUNING.INSULATION_TINY
	-- inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_TINY

	-- Handled in WorkMultiplierFn()
	-- inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.BLYTHE_WORKEFFECTIVENESS_MODIFIER, inst)
	-- inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.BLYTHE_WORKEFFECTIVENESS_MODIFIER, inst)
	-- inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.BLYTHE_WORKEFFECTIVENESS_MODIFIER, inst)

	inst.components.workmultiplier:SetSpecialMultiplierFn(WorkMultiplierFn)

	inst.components.combat.damagemultiplier = TUNING.BLYTHE_DAMAGE_MULT

	-- inst:ListenForEvent("ms_becameghost", OnBecomeXParasite)
	inst:ListenForEvent("toolbroke", OnToolBroken)

	inst:DoTaskInTime(1, function()
		local new_skills = inst.components.blythe_skiller:LearnRootSkills()

		if #new_skills > 0 then
			inst:DoTaskInTime(0.5, function()
				for _, name in pairs(new_skills) do
					local key = StarIliadBasic.GetSkillDefine(name).default_key
					if key and StarIliadBasic.IsCastByButton(name) then
						SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["set_skill_key"], inst.userid, key, name, true)
					end
				end
			end)
		end
	end)

	-- inst:DoTaskInTime(1.5, function()
	-- 	SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["set_root_skill_key"], inst.userid)
	-- end)

	-- 	function BlytheSkiller:SetRootInputHandler()
	--     for _, v in pairs(BLYTHE_SKILL_DEFINES) do
	--         if v.root
	--             and self:IsLearned(v.name)
	--             and StarIliadBasic.IsCastByButton(v.name)
	--             and v.default_key
	--             and not self:KeyHasBeenUsed(v.default_key)
	--             and not self:SkillHasBeenKeyed(v.name) then
	--             self:SetInputHandler(v.default_key, v.name, true)
	--         end
	--     end
	-- end
end

return MakePlayerCharacter("blythe", prefabs, assets, common_postinit, master_postinit, start_inv)
