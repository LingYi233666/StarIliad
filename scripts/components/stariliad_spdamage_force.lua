local SourceModifierList = require("util/sourcemodifierlist")

local StarIliadSpDamageForce = Class(function(self, inst)
    self.inst = inst
    self.basedamage = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function StarIliadSpDamageForce:SetBaseDamage(damage)
    self.basedamage = damage
end

function StarIliadSpDamageForce:GetBaseDamage()
    return self.basedamage
end

function StarIliadSpDamageForce:GetDamage()
    return self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageForce:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function StarIliadSpDamageForce:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function StarIliadSpDamageForce:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageForce:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function StarIliadSpDamageForce:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function StarIliadSpDamageForce:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function StarIliadSpDamageForce:GetDebugString()
    return string.format("Damage=%.2f [%.2fx%.2f+%.2f]", self:GetDamage(), self:GetBaseDamage(), self:GetMultiplier(),
        self:GetBonus())
end

return StarIliadSpDamageForce
