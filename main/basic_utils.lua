StarIliadBasic = {}

function StarIliadBasic.IsWearingArmor(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if (v.components.armor ~= nil or v.components.resistance ~= nil)
            and not v:HasTag("ignore_stariliad_armor_limit") then
            return true
        end
    end

    return false
end

function StarIliadBasic.GetFaceVector(inst)
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)

    return Vector3(sinangle, 0, cosangle)
end

function StarIliadBasic.GetFaceAngle(inst, target)
    local myangle = inst:GetRotation()
    local faceguyangle = inst:GetAngleToPoint(target:GetPosition():Get())
    local deltaangle = math.abs(myangle - faceguyangle)
    if deltaangle > 180 then
        deltaangle = 360 - deltaangle
    end

    return deltaangle
end

function StarIliadBasic.GetSkillDefine(name)
    name = name:lower()

    for _, data in pairs(BLYTHE_SKILL_DEFINES) do
        if data.name == name then
            return data
        end
    end
end

function StarIliadBasic.HasGravityControl(inst)
    return (inst.components.blythe_skiller and inst.components.blythe_skiller:IsLearned("gravity_control"))
        or (inst.replica.blythe_skiller and inst.replica.blythe_skiller:IsLearned("gravity_control"))
end

function StarIliadBasic.IsCastByButton(name)
    local skill_define = StarIliadBasic.GetSkillDefine(name)
    return skill_define and
        (skill_define.on_pressed or skill_define.on_released or skill_define.on_pressed_client or
            skill_define.on_released_client)
end

-- COLLISION =
-- {
--     GROUND            = 32,
--     BOAT_LIMITS       = 64,
--     LAND_OCEAN_LIMITS = 128,           -- physics wall between water and land
--     LIMITS            = 128 + 64,      -- BOAT_LIMITS + LAND_OCEAN_LIMITS
--     WORLD             = 128 + 64 + 32, -- BOAT_LIMITS + LAND_OCEAN_LIMITS + GROUND
--     ITEMS             = 256,
--     OBSTACLES         = 512,
--     CHARACTERS        = 1024,
--     FLYERS            = 2048,
--     SANITY            = 4096,
--     SMALLOBSTACLES    = 8192,  -- collide with characters but not giants
--     GIANTS            = 16384, -- collide with obstacles but not small obstacles
-- }

function StarIliadBasic.MakeCollidableProjectilePhysics(inst, mass, rad)
    mass = mass or 1
    rad = rad or .25
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(.1)
    phys:SetDamping(0)
    phys:SetRestitution(.5)
    phys:SetCollisionGroup(COLLISION.ITEMS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:SetSphere(rad)
    return phys
end

function StarIliadBasic.GetProjectileDefine(prefab)
    if prefab == nil then
        return
    end

    for _, v in pairs(STARILIAD_PROJECTILE_DEFINES) do
        if v.prefab == prefab then
            return v
        end
    end
end

function StarIliadBasic.CanCostProjectile(inst, weapon, proj_data)
    if proj_data.costs == nil then
        return true
    end

    for name, cost_data in pairs(proj_data.costs) do
        if cost_data.can_cost then
            local success, reason = cost_data.can_cost(inst, weapon)
            if not success then
                return false, reason
            end
        end
    end

    return true
end

function StarIliadBasic.PlayShootSound(inst, weapon)
    weapon = weapon or inst.sg.statemem.weapon
    if weapon == nil or weapon.replica.stariliad_pistol == nil then
        return
    end

    local proj_data = weapon.replica.stariliad_pistol:GetProjectileData()
    if proj_data == nil or proj_data.sound == nil then
        return
    end

    if StarIliadBasic.CanCostProjectile(inst, weapon, proj_data) then
        inst.SoundEmitter:PlaySound(proj_data.sound, nil, nil, true)
    else
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/clip_empty", nil, nil, true)
    end
end

function StarIliadBasic.DamageSum(...)
    local total = 0

    for _, v in pairs({ ... }) do
        if v then
            if type(v) == "number" then
                total = total + v
            elseif type(v) == "table" then
                for _, v2 in pairs(v) do
                    total = total + v2
                end
            end
        end
    end

    return total
end

function StarIliadBasic.IsShieldState(target)
    return target and target:IsValid() and target.sg and target.sg.currentstate.name == "shield"
end

function StarIliadBasic.TryBreakShieldState(target)
    if not StarIliadBasic.IsShieldState(target) then
        return
    end

    -- target:PushEvent("exitshield")

    if not (target.brain and target.brain.bt and target.brain.bt.root) then
        return
    end

    local use_shield_nodes = {}
    local queue = { target.brain.bt.root }

    while #queue > 0 do
        local node = table.remove(queue, 1)
        if node.name == "UseShield" then
            table.insert(use_shield_nodes, node)
        end

        if node.children then
            for _, v in pairs(node.children) do
                table.insert(queue, v)
            end
        end
    end

    for _, node in pairs(use_shield_nodes) do
        -- print("Process UseShield:", node)
        node.scareendtime = 0
        node.damagetaken = 0
        node.timelastattacked = 0
        node.status = SUCCESS
        -- print(node:TimeToEmerge())
    end

    if target.sg.sg.events["exitshield"] then
        target.sg:HandleEvent("exitshield")
    else
        target:PushEvent("exitshield")
    end
end

function StarIliadBasic.IsWorthyEnemy(inst, target)
    return target
        and target:IsValid()
        and target.components.combat
        and target.components.combat:CalcDamage(inst) > 1
end

function StarIliadBasic.SpawnSupplyBalls(attacker, pos)
    local counter = attacker.components.blythe_missile_counter
    local skiller = attacker.components.blythe_skiller

    local num_missiles = counter:GetNumMissiles()
    local max_num_missiles = counter:GetMaxNumMissiles()
    local num_super_missiles = counter:GetNumSuperMissiles()
    local max_num_super_missiles = counter:GetMaxNumSuperMissiles()

    local learned_missile = skiller:IsLearned("missile")
    local learned_super_missile = skiller:IsLearned("super_missile")

    local candidates = {}
    if learned_missile and num_missiles < max_num_missiles then
        candidates.blythe_supply_ball_missile = 1.0 - num_missiles / max_num_missiles
    end
    if learned_super_missile and num_super_missiles < max_num_super_missiles then
        candidates.blythe_supply_ball_super_missile = 1.0 - num_super_missiles / max_num_super_missiles
    end

    local prefab = weighted_random_choice(candidates)
    if prefab then
        local ball = SpawnPrefab(prefab)
        ball:Setup(attacker, pos)
    end
end

function StarIliadBasic.GetCurrentStateName(inst)
    if inst and inst:IsValid() and inst.sg and inst.sg.currentstate then
        return inst.sg.currentstate.name
    end
end

function StarIliadBasic.RemoveOneItem(item)
    if item.components.stackable then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end
end

GLOBAL.StarIliadBasic = StarIliadBasic
