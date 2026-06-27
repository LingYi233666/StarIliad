local assets =
{
    Asset("ANIM", "anim/cursed_beads.zip"),
    Asset("INV_IMAGE", "cursed_beads1"),
    Asset("INV_IMAGE", "cursed_beads2"),
    Asset("INV_IMAGE", "cursed_beads3"),
    Asset("INV_IMAGE", "cursed_beads4"),
}

local function OnActive(inst, owner)
    inst._poison_task = inst:DoPeriodicTask(1, function()
        -- TODO: Damage owner with poison
    end)
end

local function OnDeActive(inst, owner)
    if inst._poison_task then
        inst._poison_task:Cancel()
    end
    inst._poison_task = nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cursedbeads")
    inst.AnimState:SetBuild("cursed_beads")
    inst.AnimState:PlayAnimation("idle1")

    inst:AddTag("cattoy")
    inst:AddTag("nosteal")
    inst:AddTag("cursed")

    inst.stariliad_useable_item_str = "POISON"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem.keepondrown = true
    StarIliadDebug.SetDebugInventoryImage(inst)

    -- inst:AddComponent("stackable")
    -- inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("curseditem")
    inst.components.curseditem.curse = "STARILIAD_CURSE_POISON"

    inst:AddComponent("stariliad_inventory_effect_item")
    inst.components.stariliad_inventory_effect_item:SetOnActivateFn(OnActive)
    inst.components.stariliad_inventory_effect_item:SetOnDeactivateFn(OnDeActive)

    inst:AddComponent("stariliad_useable_item")
    inst.components.stariliad_useable_item:SetMaxRemoveSize(3)
    inst.components.stariliad_useable_item:SetActionDuration(5)
    inst.components.stariliad_useable_item:SetUseActionMeter(true)

    return inst
end


return Prefab("stariliad_curse_poison", fn, assets)
