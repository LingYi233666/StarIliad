local StarIliadPistol = Class(function(self, inst)
    self.inst = inst

    -- self._main_projectile_prefab = net_string(inst.GUID, "StarIliadPistol._main_projectile_prefab",
    --     "StarIliadPistol._main_projectile_prefab")
    -- self._main_projectile_data = nil

    -- self._sub_projectile_prefab = net_string(inst.GUID, "StarIliadPistol._sub_projectile_prefab",
    --     "StarIliadPistol._sub_projectile_prefab")
    -- self._sub_projectile_data = nil

    -- inst:ListenForEvent("StarIliadPistol._main_projectile_prefab", function()
    --     self._main_projectile_data = StarIliadBasic.GetProjectileDefine(self._main_projectile_prefab:value())
    -- end)

    -- inst:ListenForEvent("StarIliadPistol._sub_projectile_prefab", function()
    --     self._sub_projectile_data = StarIliadBasic.GetProjectileDefine(self._sub_projectile_prefab:value())
    -- end)

    self._projectile_prefab = net_string(inst.GUID, "StarIliadPistol._projectile_prefab",
        "StarIliadPistol._projectile_prefab")
    self._projectile_data = nil

    inst:ListenForEvent("StarIliadPistol._projectile_prefab", function()
        self._projectile_data = StarIliadBasic.GetProjectileDefine(self._projectile_prefab:value())
    end)
end)

-- function StarIliadPistol:SetMainProjectilePrefab(val)
--     self._main_projectile_prefab:set(val)
-- end

-- function StarIliadPistol:SetSubProjectilePrefab(val)
--     self._sub_projectile_prefab:set(val)
-- end

-- function StarIliadPistol:GetMainProjectileData()
--     return self._main_projectile_data
-- end

-- function StarIliadPistol:GetSubProjectileData()
--     return self._main_projectile_data
-- end

function StarIliadPistol:SetProjectilePrefab(val)
    self._projectile_prefab:set(val)
end

function StarIliadPistol:GetProjectileData()
    return self._projectile_data
end

return StarIliadPistol
