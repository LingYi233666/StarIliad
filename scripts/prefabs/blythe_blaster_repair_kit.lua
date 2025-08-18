local function OnRepaired(inst, target, doer)
    doer:PushEvent("repair")
end

local assets =
{
    Asset("ANIM", "anim/blythe_blaster_repair_kit.zip"),

    Asset("IMAGE", "images/inventoryimages/blythe_blaster_repair_kit.tex"),
    Asset("ATLAS", "images/inventoryimages/blythe_blaster_repair_kit.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blythe_blaster_repair_kit")
    inst.AnimState:SetBuild("blythe_blaster_repair_kit")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("stackable")
    -- inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("forgerepair")
    inst.components.forgerepair:SetRepairMaterial(FORGEMATERIALS.BLYTHE_BLASTER)
    inst.components.forgerepair:SetOnRepaired(OnRepaired)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "blythe_blaster_repair_kit"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_blaster_repair_kit.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("blythe_blaster_repair_kit", fn, assets)
