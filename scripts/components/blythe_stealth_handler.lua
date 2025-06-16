local SourceModifierList = require("util/sourcemodifierlist")

local BlytheStealthHandler = Class(function(self, inst)
    self.inst = inst

    self.stealth_sources = SourceModifierList(inst, false, SourceModifierList.boolean)
end)

-- ThePlayer.components.blythe_stealth_handler:AddModifier(ThePlayer,"debug")
function BlytheStealthHandler:AddModifier(source, key)
    self.stealth_sources:SetModifier(source, true, key)
    self:CheckModifier()
end

function BlytheStealthHandler:RemoveModifier(source, key)
    self.stealth_sources:RemoveModifier(source, key)
    self:CheckModifier()
end

function BlytheStealthHandler:CheckModifier()
    if self.stealth_sources:Get() then
        self.inst:AddTag("stealth")
    else
        self.inst:RemoveTag("stealth")
    end
end

return BlytheStealthHandler
