local BlytheSkillSpeedBurst = Class(function(self, inst)
    self.inst = inst
    self._in_speed_burst = net_bool(inst.GUID, "BlytheSkillSpeedBurst._in_speed_burst",
        "BlytheSkillSpeedBurst._in_speed_burst")
    self._in_speed_burst:set(false)
end)

function BlytheSkillSpeedBurst:SetInSpeedBurst(val)
    self._in_speed_burst:set(val)
end

function BlytheSkillSpeedBurst:IsInSpeedBurst()
    return self._in_speed_burst:value()
end

return BlytheSkillSpeedBurst
