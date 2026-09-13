local assets =
{
    Asset("ANIM", "anim/stariliad_shroom_skin_part.zip"),

    Asset("ATLAS", "images/inventoryimages/stariliad_shroom_skin_part_1.xml"),
    Asset("IMAGE", "images/inventoryimages/stariliad_shroom_skin_part_1.tex"),

    Asset("ATLAS", "images/inventoryimages/stariliad_shroom_skin_part_2.xml"),
    Asset("IMAGE", "images/inventoryimages/stariliad_shroom_skin_part_2.tex"),

    Asset("ATLAS", "images/inventoryimages/stariliad_shroom_skin_part_3.xml"),
    Asset("IMAGE", "images/inventoryimages/stariliad_shroom_skin_part_3.tex"),

    Asset("ATLAS", "images/inventoryimages/stariliad_shroom_skin_part_4.xml"),
    Asset("IMAGE", "images/inventoryimages/stariliad_shroom_skin_part_4.tex"),
}

local function SetImageIndex(inst, image_index)
    inst.image_index = image_index

    local anim = "idle_0" .. tostring(image_index)
    print(inst, "Setting animation: ", anim)
    inst.AnimState:PlayAnimation(anim)
    inst.components.inventoryitem.imagename = "stariliad_shroom_skin_part_" .. image_index
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_shroom_skin_part_" ..
        image_index .. ".xml"
end

local function OnSave(inst, data)
    if inst.image_index ~= nil then
        data.image_index = inst.image_index
    end
end

local function OnLoad(inst, data)
    if data.image_index ~= nil then
        SetImageIndex(inst, data.image_index)
    end
end

local function common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_shroom_skin_part")
    inst.AnimState:SetBuild("stariliad_shroom_skin_part")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "large", nil, 0.6)

    inst:SetPrefabName("stariliad_shroom_skin_part")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    StarIliadDebug.SetDebugInventoryImage(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)


    return inst
end

local function fn_random()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end


    SetImageIndex(inst, math.random(1, 4))

    return inst
end

local function fn_1()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    SetImageIndex(inst, 1)

    return inst
end

local function fn_2()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    SetImageIndex(inst, 2)

    return inst
end

local function fn_3()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    SetImageIndex(inst, 3)

    return inst
end

local function fn_4()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    SetImageIndex(inst, 4)

    return inst
end

return Prefab("stariliad_shroom_skin_part", fn_random, assets),
    Prefab("stariliad_shroom_skin_part_1", fn_1, assets),
    Prefab("stariliad_shroom_skin_part_2", fn_2, assets),
    Prefab("stariliad_shroom_skin_part_3", fn_3, assets),
    Prefab("stariliad_shroom_skin_part_4", fn_4, assets)
