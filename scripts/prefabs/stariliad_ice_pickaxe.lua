local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/pickaxe.zip"),
    Asset("ANIM", "anim/swap_pickaxe.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_pickaxe", "swap_pickaxe")
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

    inst.AnimState:SetBank("pickaxe")
    inst.AnimState:SetBuild("pickaxe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    MakeInventoryFloatable(inst, "med", 0.05, { 0.75, 0.4, 0.75 })
    inst.components.floater:SetBankSwapOnFloat(true, -11, { sym_build = "swap_pickaxe" })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    StarIliadDebug.SetDebugInventoryImage(inst)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, 1)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PICK_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    StarIliadIceCraftCommon.AddPerishable(inst)

    StarIliadIceCraftCommon.AddHeater(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stariliad_ice_pickaxe", fn, assets)
