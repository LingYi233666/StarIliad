local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"

local StarIliadUsurperShotArrows = require "widgets/stariliad_usurper_shot_arrows"

local StarIliadUsurperShotScreen = Class(Screen, function(self, target1, target2)
	Screen._ctor(self, "StarIliadUsurperShotScreen")

	self.stars = self:AddChild(Image("images/ui/stariliad_8star.xml", "stariliad_8star.tex"))
	self.stars:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.stars:SetVAnchor(ANCHOR_MIDDLE)
	self.stars:SetHAnchor(ANCHOR_MIDDLE)
	self.stars:SetEffect(resolvefilepath("shaders/8star.ksh"))
	self.stars:SetEffectParams(-1, -1, 0, 0)
	self.stars:SetEffectParams2(-1, -1, 0, 0)
	self.stars:SetTint(0, 0, 0, 0.8)
	self.stars:SetClickable(false)

	self.arrows_1 = self:AddChild(StarIliadUsurperShotArrows(true))

	self.arrows_2 = self:AddChild(StarIliadUsurperShotArrows())

	self.targets = {}

	self:SetTargets(target1, target2)
	self:StartUpdating()
end)

local function GetRawData(target)
	local x, y, z = target.Transform:GetWorldPosition()
	local x2, y2 = TheSim:GetScreenPos(x, y, z)
	local sw, sh = 300, 300

	-- if target:HasTag("smallcreature") then
	-- 	sw, sh = 200, 200
	-- elseif target:HasTag("largecreature") then
	-- 	sw, sh = 400, 400
	-- 	y2 = y2 + 50
	-- else
	-- 	y2 = y2 + 25
	-- end

	y2 = y2 + 25


	return x2, y2, sw, sh
end

function StarIliadUsurperShotScreen:SetTargets(target1, target2)
	self.targets = {}

	if target1 then
		table.insert(self.targets, target1)
	end

	if target2 then
		table.insert(self.targets, target2)
	end

	if target1 and target2 then
		local sx1, sy1, _, _ = GetRawData(target1)
		local sx2, sy2, _, _ = GetRawData(target2)

		local forward = (Vector3(sx2, sy2, 0) - Vector3(sx1, sy1, 0)):GetNormalized()
		local axis_side = forward:Cross(Vector3(0, 0, 1)):GetNormalized()

		local offset = axis_side * 50
		local speed = 0.75

		self.arrows_1:Init(Vector3(sx1, sy1, 0) + offset, Vector3(sx2, sy2, 0) + offset, speed)
		self.arrows_2:Init(Vector3(sx2, sy2, 0) - offset, Vector3(sx1, sy1, 0) - offset, speed)
	end
end

local function GetEffectParam(target)
	local x2, y2, sw, sh = GetRawData(target)
	local w, h = TheSim:GetScreenSize()

	return { x2 / w, y2 / h, sw / w, sh / h }
end

function StarIliadUsurperShotScreen:OnUpdate()
	if self.targets[1] and self.targets[1]:IsValid() then
		self.stars:SetEffectParams(unpack(GetEffectParam(self.targets[1])))
	end

	if self.targets[2] and self.targets[2]:IsValid() then
		self.stars:SetEffectParams2(unpack(GetEffectParam(self.targets[2])))
	end

	if self.targets[1] and self.targets[2] and self.arrows_1.finish_flag and not self.sending then
		if self.targets[1]:IsValid() and self.targets[2]:IsValid() then
			SendModRPCToServer(MOD_RPC["stariliad_rpc"]["usurper_shot_teleport"], self.targets[1], self.targets[2])
			self.sending = true
		end
		self:StopUpdating()
		TheFrontEnd:PopScreen(self)
	end
end

return StarIliadUsurperShotScreen
