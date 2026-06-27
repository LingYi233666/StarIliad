local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/stariliad_ice_hammer.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_ice_hammer.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_ice_hammer.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "stariliad_ice_hammer", "swap_hammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnPerishChange(inst, data)
    inst.components.tool.actions[ACTIONS.HAMMER] =
        Remap(data.percent, 0, 1, TUNING.STARILIAD_ICE_HAMMER_TOOL_EFFECTS[1],
            TUNING.STARILIAD_ICE_HAMMER_TOOL_EFFECTS[2])
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_ice_hammer")
    inst.AnimState:SetBuild("stariliad_ice_hammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")


    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.HAMMER_DAMAGE)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_ice_hammer"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_ice_hammer.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.STARILIAD_ICE_HAMMER_TOOL_EFFECTS[2])

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

return Prefab("stariliad_ice_hammer", fn, assets)
