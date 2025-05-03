local BlytheSkillBase_Passive = Class(function(self, inst)
    self.inst = inst
    self.enable = false
end)

function BlytheSkillBase_Passive:Enable(enable, is_onload)
    self.enable = enable
end

function BlytheSkillBase_Passive:IsEnabled()
    return self.enable
end

return BlytheSkillBase_Passive
