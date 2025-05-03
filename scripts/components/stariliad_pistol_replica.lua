local StarIliadPistol = Class(function(self, inst)
    self.inst = inst

    self._projectile_prefab = net_string(inst.GUID, "StarIliadPistol._projectile_prefab",
        "StarIliadPistol._projectile_prefab")
end)

function StarIliadPistol:SetProjectilePrefab(val)
    self._projectile_prefab:set(val)
end

function StarIliadPistol:GetProjectileData()
    if self.inst.components.stariliad_pistol then
        return self.inst.components.stariliad_pistol:GetProjectileData()
    end

    local data = StarIliadBasic.GetProjectileDefine(self._projectile_prefab:value())
    return data
end

return StarIliadPistol
