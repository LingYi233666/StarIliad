local StarIliadIceCraftCommon = require("prefabs/stariliad_ice_craft_common")

local assets =
{
    Asset("ANIM", "anim/stariliad_bingbong.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_bingbong.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_bingbong.xml"),

    Asset("IMAGE", "images/map_icons/stariliad_bingbong.tex"), --小地图
    Asset("ATLAS", "images/map_icons/stariliad_bingbong.xml"),
}

-- local function doll_swap_object_helper(owner, skin_build, symbol, guid)
--     if skin_build ~= nil then
--         owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, symbol, guid, "bernie_build")
--         owner.AnimState:OverrideItemSkinSymbol("swap_object_bernie", skin_build, symbol .. "_idle_willow", guid,
--             "bernie_build")
--     else
--         owner.AnimState:OverrideSymbol("swap_object", "bernie_build", symbol)
--         owner.AnimState:OverrideSymbol("swap_object_bernie", "bernie_build", symbol .. "_idle_willow")
--     end
-- end

local function OnEquip(inst, owner)
    -- if inst:GetSkinBuild() ~= nil then
    --     owner:PushEvent("equipskinneditem", inst:GetSkinName())
    -- end

    -- doll_swap_object_helper(owner, inst:GetSkinBuild(), "swap_bernie", inst.GUID)

    -- owner.AnimState:OverrideSymbol("swap_object_bernie", "stariliad_bingbong", "swap_bernie")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "stariliad_bingbong", "swap_bingbong")

    inst.components.fueled:StartConsuming()
end

local function OnUnequip(inst, owner)
    -- local skin_build = inst:GetSkinBuild()
    -- if skin_build ~= nil then
    --     owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    -- end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.fueled:StopConsuming()
end

local function OnEquipToModel(inst, owner, from_ground)
    inst.components.fueled:StopConsuming()
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_bingbong")
    inst.AnimState:SetBuild("stariliad_bingbong")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("stariliad_bingbong.tex")

    inst:AddTag("nopunch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_bingbong"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_bingbong.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_HUGE
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.STARILIAD_BINGBONG_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    StarIliadIceCraftCommon.AddHeater(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stariliad_bingbong", fn, assets)
