local BlytheSkillStealth = Class(function(self, inst)
    self.inst = inst

    self._is_visible = net_bool(inst.GUID, "BlytheSkillStealth._is_visible", "blythe_skill_visible_dirty")
    self._is_visible:set(false)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("blythe_skill_visible_dirty", function()
            self:IsVisibleDirty()
        end)
    end
end)

function BlytheSkillStealth:SetIsVisible(val)
    self._is_visible:set(val)
end

function BlytheSkillStealth:IsVisible()
    return self._is_visible:value()
end

function BlytheSkillStealth:IsVisibleDirty()
    if self._is_visible:value() then
        if ThePlayer == self.inst then
            self.inst.AnimState:OverrideMultColour(10 / 255, 240 / 255, 230 / 255, 0.4)
            self.inst.AnimState:SetHaunted(true)
        else
            self.inst:Hide()
        end
    else
        if ThePlayer == self.inst then
            -- nil means clear OverrideMultColour
            self.inst.AnimState:OverrideMultColour()
            self.inst.AnimState:SetHaunted(false)
        else
            self.inst:Show()
        end
    end
end

return BlytheSkillStealth
