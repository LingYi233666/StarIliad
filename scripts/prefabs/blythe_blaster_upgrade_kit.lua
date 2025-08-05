local function OnRepaired(inst, target, doer)
    doer:PushEvent("repair")
end

local assets =
{
    Asset("ANIM", "anim/sewing_kit.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sewing_kit")
    inst.AnimState:SetBuild("sewing_kit")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("upgrader")
    inst.components.upgrader.upgradetype = UPGRADETYPES.DEFAULT

    inst:AddComponent("inventoryitem")
    StarIliadDebug.SetDebugInventoryImage(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("blythe_blaster_upgrade_kit", fn, assets)
