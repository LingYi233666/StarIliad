local SourceModifierList = require("util/sourcemodifierlist")

local StarIliadSpDefenseForce = Class(function(self, inst)
    self.inst = inst
    self.basedefense = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function StarIliadSpDefenseForce:SetBaseDefense(defense)
    self.basedefense = defense
end

function StarIliadSpDefenseForce:GetBaseDefense()
    return self.basedefense
end

function StarIliadSpDefenseForce:GetDefense()
    return self.basedefense * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseForce:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function StarIliadSpDefenseForce:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function StarIliadSpDefenseForce:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseForce:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function StarIliadSpDefenseForce:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function StarIliadSpDefenseForce:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDefenseForce:GetDebugString()
    return string.format("Defense=%.2f [%.2fx%.2f+%.2f]", self:GetDefense(), self:GetBaseDefense(), self:GetMultiplier(),
        self:GetBonus())
end

return StarIliadSpDefenseForce
