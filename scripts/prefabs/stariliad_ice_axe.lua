local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/axe.zip"),
    Asset("ANIM", "anim/swap_axe.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_axe", "swap_axe")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("axe")
    inst.AnimState:SetBuild("axe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")


    MakeInventoryFloatable(inst, "small", 0.05, { 1.2, 0.75, 1.2 })
    inst.components.floater:SetBankSwapOnFloat(true, -11, { sym_build = "swap_axe" })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    StarIliadDebug.SetDebugInventoryImage(inst)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    StarIliadIceCraftCommon.AddPerishable(inst)

    StarIliadIceCraftCommon.AddHeater(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stariliad_ice_axe", fn, assets)
