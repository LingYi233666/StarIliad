local assets =
{
    Asset("ANIM", "anim/blythe_missile.zip"),
}


local function CollisionCallback(inst, other)
    if other and not other:HasTag("pond")
        and inst.components.complexprojectile.attacker ~= nil
        and other ~= inst.components.complexprojectile.attacker then
        inst.components.complexprojectile:Hit(other)
    end
end

local function CanInteract(inst, target, my_range)
    local dist = math.sqrt(inst:GetDistanceSqToInst(target))
    my_range = my_range or inst:GetPhysicsRadius(0)

    return dist < my_range + target:GetPhysicsRadius(0)
end


local function OnHit(inst, attacker, target)
    if type(inst.explode_prefab) == "string" then
        SpawnAt(inst.explode_prefab, inst)
    else
        for _, v in pairs(inst.explode_prefab) do
            SpawnAt(v, inst)
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, inst.explode_range + 2, nil, { "INLIMBO", "FX" })
    for k, v in pairs(ents) do
        if v:IsValid() and CanInteract(inst, v, inst.explode_range) then
            -- if attacker.components.combat and attacker.components.combat:CanTarget(v) then
            if not IsEntityDeadOrGhost(v, true) and v.components.combat and v.components.combat:CanBeAttacked(attacker) then
                -- StarIliadBasic.TryBreakShieldState(target)
                attacker.components.combat:DoAttack(v, inst, inst, nil, nil, math.huge)
                v:AddDebuff("stariliad_debuff_shield_break", "stariliad_debuff_shield_break")
            elseif v.components.workable and v.components.workable:CanBeWorked() and v.components.workable.action ~= ACTIONS.NET then
                v.components.workable:WorkedBy(attacker, inst.work_damage)
            end
        end
    end

    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .2, inst, 40)

    inst.SoundEmitter:KillSound("missile_loop")

    inst:Remove()
end


local function OnUpdate(inst)
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

    if inst.entity:IsVisible() then
        if not inst.anim then
            inst.anim = inst:SpawnChild(inst.anim_prefab)
            inst.anim.entity:AddFollower()
            inst.anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        if not inst.tail then
            inst.tail = inst:SpawnChild(inst.tail_prefab)
            inst.tail.entity:AddFollower()
            inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 3, nil, { "INLIMBO", "FX" })
    for k, v in pairs(ents) do
        -- if (attacker.components.combat
        --         and attacker.components.combat:CanTarget(v)
        --         and not attacker.components.combat:IsAlly(v))

        if (v.components.combat
                and v.components.combat:CanBeAttacked(attacker)
                and attacker.components.combat
                and attacker.components.combat:IsValidTarget(v))
            or (v.components.workable
                and v.components.workable:CanBeWorked()
                and v.components.workable.action ~= ACTIONS.NET
                and v.components.workable.action ~= ACTIONS.DIG) then
            if CanInteract(inst, v, 0.5) then
                inst.components.complexprojectile:Hit(v)
                break
            end
        end
    end


    return true
end



local function MakeMissile(prefab, anim_prefab, tail_prefab, explode_prefab, explode_range, normal_damage, damage,
                           work_damage)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddSoundEmitter()

        StarIliadBasic.MakeCollidableProjectilePhysics(inst)

        inst.AnimState:SetBank("stariliad_height_controller")
        inst.AnimState:SetBuild("stariliad_height_controller")
        inst.AnimState:PlayAnimation("no_face")

        inst.AnimState:SetMultColour(0, 0, 0, 0)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.anim_prefab = anim_prefab
        inst.tail_prefab = tail_prefab
        inst.explode_prefab = explode_prefab
        inst.explode_range = explode_range
        inst.work_damage = work_damage

        inst.Physics:SetCollisionCallback(CollisionCallback)

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(normal_damage)

        inst:AddComponent("planardamage")
        inst.components.planardamage:SetBaseDamage(1)

        inst:AddComponent("stariliad_spdamage_missile")
        inst.components.stariliad_spdamage_missile:SetBaseDamage(damage)

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(TUNING.BLYTHE_MISSILE_SPEED)
        inst.components.complexprojectile:SetOnHit(OnHit)
        inst.components.complexprojectile.onupdatefn = OnUpdate

        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/missile_loop", "missile_loop")

        return inst
    end

    return Prefab(prefab, fn, assets)
end

local function MakeAnim(prefab, anim)
    local function arrow_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("blythe_missile")
        inst.AnimState:SetBuild("blythe_missile")
        inst.AnimState:PlayAnimation(anim)

        -- inst.Transform:SetScale(1, 0.8, 1)

        inst.AnimState:SetLightOverride(1)

        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

        -- local s = 1.5
        -- inst.AnimState:SetScale(s, s, s)
        -- inst.AnimState:SetAddColour(1, 1, 0, 0)

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        return inst
    end

    return Prefab(prefab, arrow_fn, assets)
end



-- return Prefab("blythe_missile", fn, assets),
-- blythe_super_missile_tail
return
    MakeMissile("blythe_missile", "blythe_missile_anim_normal", "blythe_missile_tail",
        { "blythe_missile_explode_fx", "blythe_missile_explode_smoke_fx" },
        TUNING.BLYTHE_MISSILE_EXPLODE_RANGE, 0, TUNING.BLYTHE_MISSILE_DAMAGE, TUNING.BLYTHE_MISSILE_WORK_DAMAGE),
    MakeMissile("blythe_super_missile", "blythe_missile_anim_super", "blythe_super_missile_tail",
        "blythe_super_missile_explode_fx",
        TUNING.BLYTHE_SUPER_MISSILE_EXPLODE_RANGE, 0, TUNING.BLYTHE_SUPER_MISSILE_DAMAGE,
        TUNING.BLYTHE_SUPER_MISSILE_WORK_DAMAGE),
    MakeMissile("stariliad_hexa_ghost_missile", "blythe_missile_anim_normal", "blythe_missile_tail",
        { "blythe_missile_explode_fx", "blythe_missile_explode_smoke_fx" },
        TUNING.BLYTHE_MISSILE_EXPLODE_RANGE, TUNING.STARILIAD_HEXA_GHOST_MISSILE_DAMAGE, 0,
        TUNING.BLYTHE_MISSILE_WORK_DAMAGE),
    MakeAnim("blythe_missile_anim_normal", "idle"),
    MakeAnim("blythe_missile_anim_super", "idle_super")
