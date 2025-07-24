local SourceModifierList = require("util/sourcemodifierlist")

local StarIliadSpDefenseBase = Class(function(self, inst)
	self.inst = inst
	self.basedefense = 0
	self.externalmultipliers = SourceModifierList(inst)
	self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function StarIliadSpDefenseBase:SetBaseDefense(defense)
	self.basedefense = defense
end

function StarIliadSpDefenseBase:GetBaseDefense()
	return self.basedefense
end

function StarIliadSpDefenseBase:GetDefense()
	return self.basedefense * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseBase:AddMultiplier(src, mult, key)
	self.externalmultipliers:SetModifier(src, mult, key)
end

function StarIliadSpDefenseBase:RemoveMultiplier(src, key)
	self.externalmultipliers:RemoveModifier(src, key)
end

function StarIliadSpDefenseBase:GetMultiplier()
	return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseBase:AddBonus(src, bonus, key)
	self.externalbonuses:SetModifier(src, bonus, key)
end

function StarIliadSpDefenseBase:RemoveBonus(src, key)
	self.externalbonuses:RemoveModifier(src, key)
end

function StarIliadSpDefenseBase:GetBonus()
	return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseBase:GetDebugString()
	return string.format("Defense=%.2f [%.2fx%.2f+%.2f]", self:GetDefense(), self:GetBaseDefense(), self:GetMultiplier(),
		self:GetBonus())
end

return StarIliadSpDefenseBase
