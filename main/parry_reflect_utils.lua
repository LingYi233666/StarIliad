StarIliadParryReflect = {}

local function ProjectileReflect(prefab, inst, target)
    local another = SpawnAt(prefab, inst)
    if another then
        if another.components.projectile then
            another.components.projectile:Throw(inst, target, inst)
        elseif another.components.complexprojectile then
            another.components.complexprojectile:Launch(target:GetPosition(), inst)
        end
    end
end

local function ProjectileResetDamageReflect(prefab, damage, inst, target)
    local another = SpawnAt(prefab, inst)
    if another then
        if not another.components.weapon then
            another:AddComponent("weapon")
        end
        another.components.weapon:SetDamage(damage)

        if another.components.projectile then
            another.components.projectile:Throw(inst, target, inst)
        elseif another.components.complexprojectile then
            another.components.complexprojectile:Launch(target:GetPosition(), inst)
        end
    end
end

------------------------------------------------------
StarIliadUsurper.WhiteList = {
    blowdart_walrus = function(prefab, inst, target)
        ProjectileResetDamageReflect(prefab, TUNING.WALRUS_DAMAGE, inst, target)
    end,

    spider_web_spit = function(prefab, inst, target)
        ProjectileResetDamageReflect(prefab, TUNING.SPIDER_SPITTER_DAMAGE_RANGED, inst, target)
    end,

    bishop_charge = function(prefab, inst, target)
        ProjectileResetDamageReflect(prefab, TUNING.BISHOP_DAMAGE, inst, target)
    end,

    eye_charge = function(prefab, inst, target)
        ProjectileResetDamageReflect(prefab, TUNING.EYETURRET_DAMAGE, inst, target)
    end,

    monkeyprojectile = function(prefab, inst, target)
        local another = SpawnAt(prefab, inst)
        if another then
            if not another.components.weapon then
                another:AddComponent("weapon")
            end
            another.components.weapon:SetDamage(TUNING.MONKEY_MELEE_DAMAGE)
            another.components.projectile:SetOnHitFn(another.Remove)
            another.components.projectile:Throw(inst, target, inst)
        end
    end,

    -- spat_bomb = function(prefab, inst, target)
    --     local another = SpawnAt(prefab, inst)
    --     if another then
    --         if not another.components.weapon then
    --             another:AddComponent("weapon")
    --         end
    --         another.components.weapon:SetDamage(TUNING.PIPE_DART_DAMAGE)
    --         another.components.complexprojectile:Launch(target:GetPosition(), inst)
    --     end
    -- end,

    -- brilliance_projectile_fx

    -- waterplant_projectile
}

local normal_projectiles_prefab = {
    "blowdart_sleep",
    "blowdart_fire",
    "blowdart_pipe",
    "blowdart_yellow",

    "fire_projectile",

    "houndstooth_proj",
}

for _, v in pairs(normal_projectiles_prefab) do
    StarIliadUsurper.WhiteList[v] = ProjectileReflect
end

-- TODO: Add slingshot ammos here ?

------------------------------------------------------

function StarIliadParryReflect.GetProjectilePrefab(weapon)
    local prefab = nil

    if weapon then
        if weapon.components.projectile or weapon.components.complexprojectile then
            prefab = weapon.prefab
        elseif weapon.components.weapon and weapon.components.weapon.projectile then
            prefab = weapon.components.weapon.projectile
        end
    end

    return prefab
end

function StarIliadParryReflect.CanReflect(prefab)
    if not prefab then
        return
    end

    return StarIliadUsurper.WhiteList[prefab] ~= nil
end

function StarIliadParryReflect.Reflect(prefab, inst, target)
    local fn = StarIliadUsurper.WhiteList[prefab]
    if fn then
        fn(prefab, inst, target)
    end
end

GLOBAL.StarIliadParryReflect = StarIliadParryReflect
