local SpDamageUtil = require("components/spdamageutil")


SpDamageUtil.DefineSpType("stariliad_spdamage_force", {
    GetDamage = function(ent)
        return ent.components.stariliad_spdamage_force ~= nil
            and ent.components.stariliad_spdamage_force:GetDamage() or 0
    end,
    GetDefense = function(ent)
        return ent.components.stariliad_spdefense_force ~= nil and
            ent.components.stariliad_spdefense_force:GetDefense() or 0
    end,
})
