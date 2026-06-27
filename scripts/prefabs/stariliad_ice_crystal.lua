local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/stariliad_ice_crystal.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_ice_crystal.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_ice_crystal.xml"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_ice_crystal")
    inst.AnimState:SetBuild("stariliad_ice_crystal")
    inst.AnimState:PlayAnimation("idle")

    local s = 0.2
    inst.AnimState:SetScale(s, s)

    inst:AddTag("molebait")
    inst:AddTag("quakedebris")
    inst:AddTag("rocks")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")
    inst.components.tradable.rocktribute = 1

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_ice_crystal"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_ice_crystal.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("bait")

    StarIliadIceCraftCommon.AddPerishable(inst)
    inst.components.perishable.onperishreplacement = "rocks"

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("stariliad_ice_crystal", fn, assets)
