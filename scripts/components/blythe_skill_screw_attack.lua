local BlytheSkillBase_Passive = require("components/blythe_skill_base_passive")

local BlytheSkillScrewAttack = Class(BlytheSkillBase_Passive, function(self, inst)
    BlytheSkillBase_Passive._ctor(self, inst)
end)

function BlytheSkillScrewAttack:Enable(enable, is_onload)
    local old_enable = self.enable
    BlytheSkillBase_Passive.Enable(self, enable, is_onload)
end

return BlytheSkillScrewAttack
