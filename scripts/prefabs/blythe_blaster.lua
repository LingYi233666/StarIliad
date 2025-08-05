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

local function OnProjectilePrefabChange(inst, new_prefab, old_prefab)
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

local function OnBroken(inst)
    if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner ~= nil then
            if owner.components.inventory ~= nil then
                local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
                if item ~= nil then
                    owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
                    owner:PushEvent("toolbroke", { tool = item })
                end
            else
                owner:PushEvent("toolbroke", { tool = inst })
            end
        end
    end

    if inst.components.equippable ~= nil then
        inst:RemoveComponent("equippable")
    end

    inst:AddTag("broken")
end

local function OnRepaired(inst)
    if inst.components.equippable == nil then
        inst:AddComponent("equippable")
    end
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:RemoveTag("broken")
end

local function CanBeUpgraded(inst, item)
    local total = inst.components.finiteuses.total

    -- No need to upgrade
    if total >= TUNING.BLYTHE_BLASTER_USES_THRESHOLD then
        return false
    end

    return item and item.prefab == "blythe_blaster_upgrade_kit"
end

local function OnUpgraded(inst, upgrader, item)
    local old_percent = inst.components.finiteuses:GetPercent()
    local new_total = inst.components.finiteuses.total + TUNING.BLYTHE_BLASTER_USES_UPGRADE
    new_total = math.clamp(new_total, TUNING.BLYTHE_BLASTER_USES, TUNING.BLYTHE_BLASTER_USES_THRESHOLD)

    inst.components.finiteuses:SetMaxUses(new_total)
    inst.components.finiteuses:SetPercent(old_percent)
end

local function OnSave(inst, data)
    data.maxuses = inst.components.finiteuses.total
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.maxuses ~= nil then
            local total = math.clamp(data.maxuses, TUNING.BLYTHE_BLASTER_USES, TUNING.BLYTHE_BLASTER_USES_THRESHOLD)
            local current = inst.components.finiteuses:GetUses()
            current = math.clamp(current, 0, total)

            inst.components.finiteuses:SetMaxUses(total)
            inst.components.finiteuses:SetUses(current)
        end
    end
end

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

    inst:AddTag("allow_action_on_impassable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BLYTHE_BLASTER_USES)
    inst.components.finiteuses:SetUses(TUNING.BLYTHE_BLASTER_USES)
    inst.components.finiteuses:SetOnFinished(OnBroken)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(TUNING.BLYTHE_BLASTER_ATTACK_RANGE)
    inst.components.weapon:SetProjectile("stariliad_fake_projectile")
    inst.components.weapon:SetOnProjectileLaunch(OnProjectileLaunch)
    inst.components.weapon.attackwear = 0 -- handled in stariliad_pistol

    inst:AddComponent("stariliad_pistol")
    inst.components.stariliad_pistol:SetProjectilePrefabChangeCallback(OnProjectilePrefabChange)

    inst:AddComponent("inspectable")

    -- StarIliadDebug.SetDebugInventoryImage(inst)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "blythe_blaster"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_blaster.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.restrictedtag = "blythe"

    inst:AddComponent("forgerepairable")
    inst.components.forgerepairable:SetRepairMaterial(FORGEMATERIALS.BLYTHE_BLASTER)
    inst.components.forgerepairable:SetOnRepaired(OnRepaired)

    inst:AddComponent("upgradeable")
    inst.components.upgradeable.upgradetype = UPGRADETYPES.DEFAULT
    inst.components.upgradeable:SetOnUpgradeFn(OnUpgraded)
    inst.components.upgradeable:SetCanUpgradeFn(CanBeUpgraded)

    -- To push toolbroken event, we need a more accurate procession
    -- MakeForgeRepairable(inst, FORGEMATERIALS.BLYTHE_BLASTER, OnBroken, OnRepaired)
    MakeHauntableLaunch(inst)


    inst.OnSave = OnSave
    inst.OnLoad = OnLoad


    return inst
end

return Prefab("blythe_blaster", fn, assets)
