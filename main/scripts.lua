AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local old_FacePoint = self.FacePoint

    self.FacePoint = function(self, ...)
        if self.sg ~= nil and self.sg:HasStateTag("stariliad_no_face_point") then
            return
        end

        return old_FacePoint(self, ...)
    end
end)

AddGlobalClassPostConstruct("behaviours/useshield", "UseShield", function(self)
    local old_TimeToEmerge = self.TimeToEmerge
    local old_ShouldShield = self.ShouldShield

    self.TimeToEmerge = function(self, ...)
        if self.inst
            and self.inst:IsValid()
            and self.inst.components.debuffable
            and self.inst.components.debuffable:HasDebuff("stariliad_debuff_shield_break") then
            return true
        end
        return old_TimeToEmerge(self, ...)
    end

    self.ShouldShield = function(self, ...)
        if self.inst
            and self.inst:IsValid()
            and self.inst.components.debuffable
            and self.inst.components.debuffable:HasDebuff("stariliad_debuff_shield_break") then
            return false
        end
        return old_ShouldShield(self, ...)
    end
end)
