require "json"

local function onjson_data(self, data)
	self.inst.replica.blythe_skiller:SetJsonData(data)
end

local BlytheSkiller = Class(function(self, inst)
	self.inst = inst

	self.learned_skill = {}
	self.enabled_skill = {}

	-- self.json_data = "{}"

	self:UpdateJsonData()

	-- self.use_stariliad_reroll_data_handler = true
end, nil, {
	json_data = onjson_data,
})


function BlytheSkiller:LearnRootSkills()
	for _, v in pairs(BLYTHE_SKILL_DEFINES) do
		if v.root then
			if not self:IsLearned(v.name) then
				self:Learn(v.name)
			end
		end
	end
end

-- ThePlayer.components.blythe_skiller:Learn("PHANTOM_SWORD")
function BlytheSkiller:Learn(name, is_onload)
	if self:IsLearned(name) then
		print("Try to learn a skill you already learned:", name)
		return
	end

	local data = StarIliadBasic.GetSkillDefine(name)
	if data then
		self.learned_skill[name] = true
		if data.on_learned then
			data.on_learned(self.inst, is_onload)
		end

		self.inst:PushEvent("blythe_skill_learned", {
			name = name,
			is_onload = is_onload
		})
	else
		print("Error: skill not exists:", name)
	end

	if not is_onload then
		self:Enable(name, true, is_onload)
	end

	self:UpdateJsonData()

	return self.learned_skill[name]
end

function BlytheSkiller:Enable(name, enable, is_onload)
	if not self:IsLearned(name) then
		print("Try to change enable a skill you don't learned:", name)
		return
	end

	-- assert(self:IsLearned(name), "Try to change enable skill you don't learned: " .. name)

	if self.enabled_skill[name] == enable then
		print(name, "enable state is already:", enable)
		return
	end

	local data = StarIliadBasic.GetSkillDefine(name)
	if data then
		self.enabled_skill[name] = enable
		if data.handle_enable then
			data.handle_enable(self.inst, enable, is_onload)
		end

		self.inst:PushEvent("blythe_skiller_skill_enable", {
			name = name,
			enable = enable,
			is_onload = is_onload
		})
	else
		print("Error: skill not exists:", name)
	end

	self:UpdateJsonData()
end

-- Deprecated
-- function BlytheSkiller:Forget(name)
-- 	if not self:IsLearned(name) then
-- 		return
-- 	end

-- 	self.learned_skill[name] = nil
-- 	local data = StarIliadBasic.GetSkillDefine(name)
-- 	if data then
-- 		if data.on_forget then
-- 			data.on_forget(self.inst)
-- 		end
-- 		self.inst:PushEvent("blythe_skiller_skill_forgot", {
-- 			name = name,
-- 		})
-- 	else
-- 		print("Error:Data not found:", name)
-- 	end

-- 	self:UpdateJsonData()
-- end

function BlytheSkiller:UpdateJsonData(refresh)
	if refresh then
		self.json_data = ""
	end

	local data = {
		learned_skill = self.learned_skill,
		enabled_skill = self.enabled_skill,
	}

	self.json_data = json.encode(data)
end

function BlytheSkiller:IsLearned(name)
	return self.learned_skill[name] == true
end

function BlytheSkiller:IsEnabled(name)
	return self.enabled_skill[name] == true
end

function BlytheSkiller:GetLearnedSkill()
	local ret = {}
	for name, v in pairs(self.learned_skill) do
		if v == true then
			table.insert(ret, name)
		end
	end

	return ret
end

function BlytheSkiller:GetEnabledSkill()
	local ret = {}
	for name, v in pairs(self.enabled_skill) do
		if v == true then
			table.insert(ret, name)
		end
	end

	return ret
end

function BlytheSkiller:OnSave()
	local ret = {
		learned_skill = self:GetLearnedSkill(),
		enabled_skill = self:GetEnabledSkill(),
	}

	return ret
end

function BlytheSkiller:OnLoad(data)
	if data ~= nil then
		if data.learned_skill ~= nil then
			for k, name in pairs(data.learned_skill) do
				self:Learn(name, true)
			end
		end

		if data.enabled_skill ~= nil then
			for k, name in pairs(data.enabled_skill) do
				self:Enable(name, true, true)
			end
		end
	end
end

function BlytheSkiller:LoadForReroll(data)
	-- When return from wonkey, it seems HUD not receiving skill data, cause the skill tab missing all skills
	self.inst:DoTaskInTime(1, function()
		self:UpdateJsonData(true)
	end)

	return self:OnLoad(data)
end

function BlytheSkiller:GetDebugString()
	local s = "Learned skill:"
	for name, bool in pairs(self.learned_skill) do
		if bool then
			s = s .. name .. ","
		end
	end

	s = s .. " Enabled skill:"
	for name, bool in pairs(self.enabled_skill) do
		if bool then
			s = s .. name .. ","
		end
	end

	return s
end

return BlytheSkiller
