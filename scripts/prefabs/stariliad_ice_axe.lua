local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/stariliad_ice_axe.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_ice_axe.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_ice_axe.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "stariliad_ice_axe", "swap_axe")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnPerishChange(inst, data)
    inst.components.tool.actions[ACTIONS.CHOP] =
        Remap(data.percent, 0, 1, TUNING.STARILIAD_ICE_AXE_TOOL_EFFECTS[1],
            TUNING.STARILIAD_ICE_AXE_TOOL_EFFECTS[2])
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_ice_axe")
    inst.AnimState:SetBuild("stariliad_ice_axe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")


    -- MakeInventoryFloatable(inst, "small", 0.05, { 1.2, 0.75, 1.2 })
    -- inst.components.floater:SetBankSwapOnFloat(true, -11, { sym_build = "swap_axe" })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_ice_axe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_ice_axe.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.STARILIAD_ICE_AXE_TOOL_EFFECTS[2])

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    StarIliadIceCraftCommon.AddPerishable(inst)

    StarIliadIceCraftCommon.AddHeater(inst)

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("perishchange", OnPerishChange)

    return inst
end

return Prefab("stariliad_ice_axe", fn, assets)
