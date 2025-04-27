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

local function ProjectileOnHit(inst, attacker, target)
    SpawnAt("slingshotammo_hitfx_gunpowder", inst)

    -- 1 tiny damage make target set attacker as target
    if attacker
        and attacker:IsValid()
        and attacker.components.combat
        and attacker.components.combat:CanTarget(target) then
        target.components.combat:GetAttacked(attacker, 1, inst)
    end

    inst.components.stariliad_spdamage_force:SetBaseDamage(TUNING.BLYTHE_MISSILE_DAMAGE)
    if inst.ispvp then
        inst.components.explosive:SetPvpAttacker(attacker)
    else
        inst.components.explosive:SetAttacker(attacker)
    end
    inst.components.explosive:OnBurnt()

    inst.SoundEmitter:KillSound("missile_loop")

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

    -- if inst.entity:IsVisible() and not inst.tail then
    --     inst.tail = inst:SpawnChild("blythe_beam_basic_tail")
    --     inst.tail.entity:AddFollower()
    --     inst.tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    -- end

    if inst.entity:IsVisible() and not inst.anim then
        inst.anim = inst:SpawnChild("blythe_missile_anim_normal")
        inst.anim.entity:AddFollower()
        inst.anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)


    local attacker = inst.components.complexprojectile.attacker
    local x, y, z = inst.Transform:GetWorldPosition()

    -- local ents = TheSim:FindEntities(x, y, z, 1, { "_combat", "_health" }, { "INLIMBO" })
    -- for k, v in pairs(ents) do
    --     if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
    --         inst.components.complexprojectile:Hit(v)
    --         break
    --     end
    -- end

    local ents = TheSim:FindEntities(x, y, z, 3, { "_combat", "_health" }, { "INLIMBO" })
    for k, v in pairs(ents) do
        if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0) then
                inst.components.complexprojectile:Hit(v)
                break
            end
        end
    end


    return true
end


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

    inst.Physics:SetCollisionCallback(CollisionCallback)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("stariliad_spdamage_force")
    inst.components.stariliad_spdamage_force:SetBaseDamage(0)

    inst:AddComponent("explosive")
    inst.components.explosive.explosiverange = TUNING.BLYTHE_MISSILE_RANGE
    inst.components.explosive.explosivedamage = 0
    inst.components.explosive.lightonexplode = false

    inst:AddComponent("complexprojectile")
    -- inst.components.complexprojectile:SetLaunchOffset(Vector3(0.5, 0, 0))
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
    inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate

    inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/missile_loop", "missile_loop")

    return inst
end

local function arrow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("blythe_missile")
    inst.AnimState:SetBuild("blythe_missile")
    inst.AnimState:PlayAnimation("idle2")

    -- inst.Transform:SetScale(1, 0.8, 1)

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    local s = 1.5
    inst.AnimState:SetScale(s, s, s)
    -- inst.AnimState:SetAddColour(1, 1, 0, 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("blythe_missile", fn, assets),
    Prefab("blythe_missile_anim_normal", arrow_fn, assets)
