local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function CollisionCallback(inst, other)
    if other and not other:HasTag("pond")
        and inst.components.complexprojectile.attacker ~= nil
        and other ~= inst.components.complexprojectile.attacker
        and other.components.combat == nil
        and (inst.last_reflect_time == nil or GetTime() - inst.last_reflect_time > 5 * FRAMES) then
        -- inst.components.complexprojectile:Hit(other)


        local fx = SpawnAt("blythe_beam_yellow_hit_fx", inst)
        fx.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/beam_reflect")

        local my_pos = inst:GetPosition()
        local other_pos = other:GetPosition()
        local delta_pos = my_pos - other_pos
        local speed = Vector3(inst.Physics:GetVelocity()):GetNormalized()
        local reflection_speed = StarIliadMath.GetReflectionSpeed(other_pos, my_pos, speed)

        inst:ForceFacePoint(my_pos + reflection_speed)


        local all_rad = inst:GetPhysicsRadius(0) + other:GetPhysicsRadius(0) + 0.1
        if delta_pos:Length() < all_rad then
            my_pos = other_pos + delta_pos:GetNormalized() * all_rad
        end
        -- my_pos = my_pos + reflection_speed * 1.5

        -- inst.Transform:SetPosition(my_pos:Get())

        inst.Physics:Teleport(my_pos:Get())

        inst.last_reflect_time = GetTime()
    end
end

local function ProjectileOnHit(inst, attacker, target)
    if attacker
        and attacker:IsValid()
        and attacker.components.combat
        and attacker.components.combat:CanTarget(target) then
        attacker.components.combat:DoAttack(target, inst, inst, nil, nil, math.huge)
    end

    SpawnAt("blythe_beam_yellow_hit_fx", inst)

    inst:Remove()
end

local function ProjectileOnUpdate(inst)
    inst.max_range = inst.max_range or GetRandomMinMax(20, 25)
    inst.start_pos = inst.start_pos or inst:GetPosition()

    local dist_moved = (inst:GetPosition() - inst.start_pos):Length()
    if dist_moved >= inst.max_range then
        inst.components.complexprojectile:Hit()
        return true
    else
        if dist_moved >= 0.66 then
            inst:Show()
        else
            inst:Hide()
        end
    end

    if inst.entity:IsVisible() and not inst.tail then
        inst.tail = inst:SpawnChild("blythe_beam_basic_tail")
        inst.tail.entity:AddFollower()
        inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    if inst.entity:IsVisible() and not inst.arrow then
        inst.arrow = inst:SpawnChild("blythe_beam_basic_arrow")
        inst.arrow.entity:AddFollower()
        inst.arrow.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 1, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(ents) do
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            inst.components.complexprojectile:Hit(v)
            break
        end
    end

    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    StarIliadBasic.MakeCollidableProjectilePhysics(inst)

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(CollisionCallback)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("stariliad_spdamage_force")
    inst.components.stariliad_spdamage_force:SetBaseDamage(TUNING.BLYTHE_BEAM_BASIC_DAMAGE)

    inst:AddComponent("complexprojectile")
    -- inst.components.complexprojectile:SetLaunchOffset(Vector3(0.5, 0, 0))
    inst.components.complexprojectile:SetHorizontalSpeed(34)
    inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
    inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate

    return inst
end

local function arrow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("attack_3")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetAddColour(1, 1, 0, 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    return inst
end

return Prefab("blythe_beam_basic", fn, assets),
    Prefab("blythe_beam_basic_arrow", arrow_fn, assets)
