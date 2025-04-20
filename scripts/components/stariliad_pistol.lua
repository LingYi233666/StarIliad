-- local function onmain_projectile_prefab(self, val)
--     self.inst.replica.stariliad_pistol:SetMainProjectilePrefab(val)
-- end

-- local function onsub_projectile_prefab(self, val)
--     self.inst.replica.stariliad_pistol:SetSubProjectilePrefab(val)
-- end

local function onprojectile_prefab(self, val)
    self.inst.replica.stariliad_pistol:SetProjectilePrefab(val)
end

local StarIliadPistol = Class(function(self, inst)
    self.inst = inst

    -- self.main_projectile_prefab = "blythe_beam_basic"
    -- self.main_projectile_data = nil

    -- self.sub_projectile_prefab = "blythe_missile"
    -- self.sub_projectile_data = nil

    self.projectile_prefab = "blythe_beam_basic"

    self:SetProjectilePrefab(self.projectile_prefab)
end, nil, {
    -- main_projectile_prefab = onmain_projectile_prefab,
    -- sub_projectile_prefab = onsub_projectile_prefab,

    projectile_prefab = onprojectile_prefab,

})

-- function StarIliadPistol:SetMainProjectilePrefab(val)
--     local data = StarIliadBasic.GetProjectileDefine(val)
--     if data then
--         self.main_projectile_prefab = val
--         self.main_projectile_data = data
--     end
-- end

-- function StarIliadPistol:SetSubProjectilePrefab(val)
--     local data = StarIliadBasic.GetProjectileDefine(val)
--     if data then
--         self.sub_projectile_prefab = val
--         self.sub_projectile_data = data
--     end
-- end

-- function StarIliadPistol:GetMainProjectileData()
--     return self.main_projectile_data
-- end

-- function StarIliadPistol:GetSubProjectileData()
--     return self.sub_projectile_data
-- end

function StarIliadPistol:SetProjectilePrefab(val)
    local data = StarIliadBasic.GetProjectileDefine(val)
    if data then
        self.projectile_prefab = val
    end
end

function StarIliadPistol:GetProjectileData()
    local data = StarIliadBasic.GetProjectileDefine(self.projectile_prefab)

    return data
end

function StarIliadPistol:LaunchProjectile(attacker, target, target_pos)
    if target then
        target_pos = target:GetPosition()
    end

    -- local proj_data = is_main and self:GetMainProjectileData() or self:GetSubProjectileData()

    local proj_data = self:GetProjectileData()
    if proj_data == nil or proj_data.prefab == nil then
        return
    end

    local proj = SpawnAt(proj_data.prefab, attacker)
    if proj == nil then
        return
    end
    proj.target = target

    if proj.components.complexprojectile then
        proj.components.complexprojectile:Launch(target_pos, attacker)
    end

    if proj_data.fx then
        local cloud = SpawnAt(proj_data.fx, attacker)
        cloud.Transform:SetRotation(attacker.Transform:GetRotation())
    end

    -- if proj_data.sound then
    --     attacker.SoundEmitter:PlaySound(proj_data.sound)
    -- end

    if self.last_shoot_time then
        print(string.format("%.2f FRAMES", (GetTime() - self.last_shoot_time) / FRAMES))
    end
    self.last_shoot_time = GetTime()
end

return StarIliadPistol
