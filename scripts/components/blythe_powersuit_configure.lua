local function onprojectile_prefab(self, val)
    self.inst.replica.blythe_powersuit_configure:SetProjectilePrefab(val)
end

local BlythePowersuitConfigure = Class(function(self, inst)
    self.inst = inst

    self.projectile_prefab = "blythe_beam_basic"

    self:SetProjectilePrefab(self.projectile_prefab)
end, nil, {
    projectile_prefab = onprojectile_prefab,
})

-- ThePlayer.components.blythe_powersuit_configure:SetProjectilePrefab("blythe_beam_swap")
function BlythePowersuitConfigure:SetProjectilePrefab(val, is_onload)
    local data = StarIliadBasic.GetProjectileDefine(val)
    if data then
        self.projectile_prefab = val
    end

    local blaster = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if blaster and blaster.components.stariliad_pistol then
        blaster.components.stariliad_pistol:SetProjectilePrefab(self.projectile_prefab)
    end
end

function BlythePowersuitConfigure:OnSave()
    return {
        projectile_prefab = self.projectile_prefab,
    }
end

function BlythePowersuitConfigure:OnLoad(data)
    if data ~= nil then
        if data.projectile_prefab ~= nil then
            self:SetProjectilePrefab(data.projectile_prefab, true)
        end
    end
end

return BlythePowersuitConfigure
