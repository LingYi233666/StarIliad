local assets =
{
    Asset("ANIM", "anim/trusty_shooter.zip"),
    Asset("ANIM", "anim/swap_trusty_shooter.zip"),

    Asset("ANIM", "anim/blythe_blaster.zip"),

    Asset("IMAGE", "images/inventoryimages/blythe_blaster.tex"),
    Asset("ATLAS", "images/inventoryimages/blythe_blaster.xml"),
}

local function TryChangeSwapBuild(inst, owner)
    local swap_build = "swap_blythe_blaster"
    local proj_prefab = inst.components.stariliad_pistol.projectile_prefab
    local def = StarIliadBasic.GetProjectileDefine(proj_prefab)
    if def and def.swap_build then
        swap_build = def.swap_build
    end
    inst.swap_build = swap_build

    if owner and owner:IsValid() then
        owner.AnimState:OverrideSymbol("swap_object", "blythe_blaster", inst.swap_build)
    end
end

local function SetProjectilePrefabChange(inst, new_prefab, old_prefab)
    local owner
    if inst.components.equippable:IsEquipped() then
        owner = inst.components.inventoryitem.owner
    end
    TryChangeSwapBuild(inst, owner)
end

local function OnEquip(inst, owner)
    -- owner.AnimState:OverrideSymbol("swap_object", "blythe_blaster", "swap_blythe_blaster")
    TryChangeSwapBuild(inst, owner)

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.components.combat:SetAttackPeriod(FRAMES)
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
end

local function OnProjectileLaunch(inst, attacker, target)
    inst.components.stariliad_pistol:LaunchProjectile(attacker, target)
end

local function CanRepeatCastFn(inst)
    if inst.replica.stariliad_pistol then
        local data = inst.replica.stariliad_pistol:GetProjectileData()
        return data and data.repeat_cast
    end
end

local function CastWeaponSkill(inst, doer, pos)
    inst.components.stariliad_pistol:LaunchProjectile(doer, nil, pos)
end

-- local function ReticuleMouseTargetFnLine(inst, mousepos)
--     if TheInput then
--         local ent = TheInput:GetWorldEntityUnderMouse()

--         if ent ~= nil and ent.Transform and not ent:HasOneOfTags("NOCLICK", "FX", "INLIMBO") then
--             if ent ~= ThePlayer then
--                 local x, _, z = ent.Transform:GetWorldPosition()
--                 return Vector3(x, 0, z)
--             end
--         end
--     end

--     if mousepos ~= nil then
--         local x, y, z = inst.Transform:GetWorldPosition()
--         local dx = mousepos.x - x
--         local dz = mousepos.z - z
--         local l = dx * dx + dz * dz
--         if l <= 0 then
--             return inst.components.reticule.targetpos
--         end
--         l = 6.5 / math.sqrt(l)
--         return Vector3(x + dx * l, 0, z + dz * l)
--     end
-- end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blythe_blaster")
    inst.AnimState:SetBuild("blythe_blaster")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst:AddTag("stariliad_chain_castaoe")

    StarIliadWeaponSkill.AddAoetargetingClient(inst, "line", nil, 100)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    -- inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting.reticule.pingprefab = "stariliad_fake_reticule"
    -- inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFnLine
    inst.components.aoetargeting:SetShouldRepeatCastFn(CanRepeatCastFn)
    inst.components.aoetargeting:SetAlwaysValid(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(TUNING.BLYTHE_BLASTER_ATTACK_RANGE)
    inst.components.weapon:SetProjectile("stariliad_fake_projectile")
    inst.components.weapon:SetOnProjectileLaunch(OnProjectileLaunch)

    inst:AddComponent("stariliad_pistol")
    inst.components.stariliad_pistol:SetProjectilePrefabChangeCallback(SetProjectilePrefabChange)

    inst:AddComponent("inspectable")

    -- StarIliadDebug.SetDebugInventoryImage(inst)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "blythe_blaster"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_blaster.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    MakeHauntableLaunch(inst)

    StarIliadWeaponSkill.AddAoetargetingServer(inst, CastWeaponSkill)

    return inst
end

return Prefab("blythe_blaster", fn, assets)
