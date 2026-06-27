local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/stariliad_ice_pickaxe.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_ice_pickaxe.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_ice_pickaxe.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "stariliad_ice_pickaxe", "swap_pickaxe")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnPerishChange(inst, data)
    inst.components.tool.actions[ACTIONS.MINE] =
        Remap(data.percent, 0, 1, TUNING.STARILIAD_ICE_PICKAXE_TOOL_EFFECTS[1],
            TUNING.STARILIAD_ICE_PICKAXE_TOOL_EFFECTS[2])
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_ice_pickaxe")
    inst.AnimState:SetBuild("stariliad_ice_pickaxe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    -- MakeInventoryFloatable(inst, "med", 0.05, { 0.75, 0.4, 0.75 })
    -- inst.components.floater:SetBankSwapOnFloat(true, -11, { sym_build = "swap_pickaxe" })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    -- StarIliadDebug.SetDebugInventoryImage(inst)
    inst.components.inventoryitem.imagename = "stariliad_ice_pickaxe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_ice_pickaxe.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.STARILIAD_ICE_PICKAXE_TOOL_EFFECTS[2])

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PICK_DAMAGE)

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

return Prefab("stariliad_ice_pickaxe", fn, assets)
