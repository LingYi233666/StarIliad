local assets =
{
    Asset("ANIM", "anim/stariliad_hat_gelblob.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_hat_gelblob.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_hat_gelblob.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "stariliad_hat_gelblob", "swap_hat")
    owner.AnimState:Show("HAT")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_hat_gelblob")
    inst.AnimState:SetBuild("stariliad_hat_gelblob")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    -- inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)
    -- inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_hat_gelblob"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_hat_gelblob.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(9999)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stariliad_hat_gelblob", fn, assets)
