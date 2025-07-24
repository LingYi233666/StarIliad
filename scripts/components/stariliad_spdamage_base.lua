local SourceModifierList = require("util/sourcemodifierlist")

local StarIliadSpDamageBase = Class(function(self, inst)
    self.inst = inst
    self.basedamage = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function StarIliadSpDamageBase:SetBaseDamage(damage)
    self.basedamage = damage
end

function StarIliadSpDamageBase:GetBaseDamage()
    return self.basedamage
end

function StarIliadSpDamageBase:GetDamage()
    return self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageBase:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function StarIliadSpDamageBase:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function StarIliadSpDamageBase:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageBase:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function StarIliadSpDamageBase:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function StarIliadSpDamageBase:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageBase:GetDebugString()
    return string.format("Damage=%.2f [%.2fx%.2f+%.2f]", self:GetDamage(), self:GetBaseDamage(), self:GetMultiplier(),
        self:GetBonus())
end

return StarIliadSpDamageBase
