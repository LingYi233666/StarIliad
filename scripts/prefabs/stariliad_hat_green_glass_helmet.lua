local assets =
{
    Asset("ANIM", "anim/stariliad_hat_green_glass_helmet.zip"),
    Asset("ANIM", "anim/stariliad_hat_green_glass_helmet3.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_hat_green_glass_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_hat_green_glass_helmet.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "stariliad_hat_green_glass_helmet3", "swap_hat")
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

    inst.AnimState:SetBank("stariliad_hat_green_glass_helmet3")
    inst.AnimState:SetBuild("stariliad_hat_green_glass_helmet3")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.1)

    -- inst:AddTag("shoreonsink")

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
    inst.components.inventoryitem.imagename = "stariliad_hat_green_glass_helmet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_hat_green_glass_helmet.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable.restrictedtag = "blythe"
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET,
        TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET_ABSORPTION)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_STARILIAD_HAT_GREEN_GLASS_HELMET_PLANAR_DEF)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stariliad_hat_green_glass_helmet", fn, assets)
