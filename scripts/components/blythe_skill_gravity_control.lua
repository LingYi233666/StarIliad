local BlytheSkillBase_Passive = require("components/blythe_skill_base_passive")

local BlytheSkillGravityControl = Class(BlytheSkillBase_Passive, function(self, inst)
    BlytheSkillBase_Passive._ctor(self, inst)
end)

function BlytheSkillGravityControl:Enable(enable, is_onload)
    local old_enable = self.enable
    BlytheSkillBase_Passive.Enable(self, enable, is_onload)

    if not old_enable and enable then
        self.inst.components.combat.externaldamagetakenmultipliers:SetModifier(self.inst,
            TUNING.BLYTHE_GRAVITY_CONTROL_DAMAGE_PERCENT,
            "gravity_control")
        self.inst.components.planardefense:AddBonus(self.inst, TUNING.BLYTHE_GRAVITY_CONTROL_PLANAR_DEF,
            "gravity_control")

        -- self.inst:StartUpdatingComponent(self)
    elseif old_enable and not enable then
        -- self.inst:StopUpdatingComponent(self)

        self.inst.components.combat.externaldamagetakenmultipliers:RemoveModifier(self.inst, "gravity_control")
        self.inst.components.planardefense:RemoveBonus(self.inst, "gravity_control")

        -- self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "gravity_control")
    end
end

-- function BlytheSkillGravityControl:CalcEquipmentSpeedMult()
--     local mult = 1
--     for k, v in pairs(self.inst.components.inventory.equipslots) do
--         if v.components.equippable ~= nil then
--             local item_speed_mult = v.components.equippable:GetWalkSpeedMult()

--             mult = mult * item_speed_mult
--         end
--     end

--     return mult
-- end

-- function BlytheSkillGravityControl:OnUpdate(dt)
--     local mult = self:CalcEquipmentSpeedMult()
--     if mult < 1 then
--         local factor = 1 / mult
--         self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "gravity_control", factor)
--     else
--         self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "gravity_control")
--     end
-- end

return BlytheSkillGravityControl
