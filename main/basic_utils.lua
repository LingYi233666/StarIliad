StarIliadBasic = {}

function StarIliadBasic.GetFaceVector(inst)
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)

    return Vector3(sinangle, 0, cosangle)
end

function StarIliadBasic.GetSkillDefine(name)
    name = name:lower()

    for _, data in pairs(BLYTHE_SKILL_DEFINES) do
        if data.name == name then
            return data
        end
    end
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
    for _, v in pairs(STARILIAD_PROJECTILE_DEFINES) do
        if v.prefab == prefab then
            return v
        end
    end
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

    inst.SoundEmitter:PlaySound(proj_data.sound, nil, nil, true)
end

GLOBAL.StarIliadBasic = StarIliadBasic
