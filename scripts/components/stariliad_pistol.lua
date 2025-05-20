local function onprojectile_prefab(self, val)
    self.inst.replica.stariliad_pistol:SetProjectilePrefab(val)
end

local DEFAULT_BEAM_PREFAB = "blythe_beam_basic"

local StarIliadPistol = Class(function(self, inst)
    self.inst = inst

    self.projectile_prefab = DEFAULT_BEAM_PREFAB

    self:SetProjectilePrefab(self.projectile_prefab)

    inst:ListenForEvent("equipped", function(_, data)
        if data.owner and data.owner.components.blythe_powersuit_configure then
            self:SetProjectilePrefab(data.owner.components.blythe_powersuit_configure.projectile_prefab)
        end
    end)

    inst:ListenForEvent("unequipped", function(_, data)
        self:SetProjectilePrefab(DEFAULT_BEAM_PREFAB)
    end)
end, nil, {
    projectile_prefab = onprojectile_prefab,
})

function StarIliadPistol:SetProjectilePrefab(val)
    local data = StarIliadBasic.GetProjectileDefine(val)
    if data then
        self.projectile_prefab = val
        if data.range then
            self.inst.components.weapon:SetRange(data.range)
        else
            self.inst.components.weapon:SetRange(TUNING.BLYTHE_BLASTER_ATTACK_RANGE)
        end
    end
end

function StarIliadPistol:GetProjectileData()
    local data = StarIliadBasic.GetProjectileDefine(self.projectile_prefab)

    return data
end

local function LaunchProjectile(proj, target_pos, attacker)
    if proj.components.complexprojectile then
        proj.components.complexprojectile:Launch(target_pos, attacker)
    elseif proj.LaunchBeam then
        proj:LaunchBeam(target_pos, attacker)
    end
end

local function ApplyBeamStrengthen(inst, proj, attacker)
    if proj.prefab == "blythe_beam_basic" then
        if attacker.components.blythe_skiller then
            proj._is_wide_beam:set(attacker.components.blythe_skiller:IsEnabled("wide_beam"))
            proj._is_wave_beam:set(attacker.components.blythe_skiller:IsEnabled("wave_beam"))
            proj._is_plasma_beam:set(attacker.components.blythe_skiller:IsEnabled("plasma_beam"))

            if attacker.components.blythe_skiller:IsLearned("wave_beam") then
                proj.components.planardamage:AddBonus(attacker, TUNING.BLYTHE_BEAM_WAVE_DAMAGE_BONUS, "wave_beam")
            end

            if attacker.components.blythe_skiller:IsLearned("plasma_beam") then
                proj.components.stariliad_spdamage_force:AddBonus(attacker, TUNING.BLYTHE_BEAM_PLASMA_DAMAGE_BONUS,
                    "plasma_beam")
            end
        end
    end
end

function StarIliadPistol:LaunchProjectile(attacker, target, target_pos)
    if target then
        target_pos = target:GetPosition()
    end

    local proj_data = self:GetProjectileData()
    if proj_data == nil or proj_data.prefab == nil then
        return
    end

    local proj = SpawnAt(proj_data.prefab, attacker)
    if proj == nil then
        return
    end
    proj.target = target

    ApplyBeamStrengthen(self.inst, proj, attacker)

    LaunchProjectile(proj, target_pos, attacker)

    if proj_data.fx then
        local cloud = SpawnAt(proj_data.fx, attacker)
        cloud.Transform:SetRotation(attacker.Transform:GetRotation())
    end

    -- will handle in SG
    -- if proj_data.sound then
    --     attacker.SoundEmitter:PlaySound(proj_data.sound)
    -- end

    if self.last_shoot_time then
        print(string.format("%.2f FRAMES", (GetTime() - self.last_shoot_time) / FRAMES))
    end
    self.last_shoot_time = GetTime()
end

return StarIliadPistol
