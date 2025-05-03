local function onprojectile_prefab(self, val)
    self.inst.replica.blythe_powersuit_configure:SetProjectilePrefab(val)
end

local BlythePowersuitConfigure = Class(function(self, inst)
    self.inst = inst

    self.projectile_prefab = "blythe_beam_basic"
end, nil, {
    projectile_prefab = onprojectile_prefab,
})

-- ThePlayer.components.blythe_powersuit_configure:SetProjectilePrefab("blythe_beam_swap")
function BlythePowersuitConfigure:SetProjectilePrefab(val)
    local data = StarIliadBasic.GetProjectileDefine(val)
    if data then
        self.projectile_prefab = val
    end

    local blaster = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if blaster and blaster.components.stariliad_pistol then
        blaster.components.stariliad_pistol:SetProjectilePrefab(self.projectile_prefab)
    end
end

return BlythePowersuitConfigure
