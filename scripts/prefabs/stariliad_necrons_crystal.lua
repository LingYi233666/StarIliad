local assets =
{
    Asset("ANIM", "anim/stariliad_necrons_crystal.zip"),
}

local MAX_WORKLEFT = 10

SetSharedLootTable("stariliad_necrons_crystal",
    {
        { "marble", 1.00 },
        { "marble", 1.00 },
        { "marble", 0.33 },
    }
)

local function CheckAnimAndLight(inst)
    if inst.anim_index == nil then
        inst.anim_index = math.random(1, 3)
    end

    local workleft = inst.components.workable:GetWorkLeft()

    local anim =
        (workleft < MAX_WORKLEFT / 3 and "low") or
        (workleft < MAX_WORKLEFT * 2 / 3 and "med") or
        "full"

    if workleft >= MAX_WORKLEFT * 2 / 3 then
        anim = "full"
        inst._light_mode:set(2)
    elseif workleft >= MAX_WORKLEFT / 3 then
        anim = "med"
        inst._light_mode:set(1)
    else
        anim = "low"
        inst._light_mode:set(0)
    end

    inst.AnimState:PlayAnimation(anim .. inst.anim_index)
end

local function OnWorked(inst, worker, workleft)
    if workleft <= 0 then
        SpawnAt("rock_break_fx", inst)
        inst.components.lootdropper:DropLoot()
        inst:Remove()
    else
        CheckAnimAndLight(inst)
    end
end

local function OnLightModeDirty(inst)
    local val = inst._light_mode:value()
    if val == 0 then
        inst.Light:SetRadius(0.55)
        inst.Light:Enable(true)
    elseif val == 1 then
        inst.Light:SetRadius(0.9)
        inst.Light:Enable(true)
    elseif val == 2 then
        inst.Light:SetRadius(1.2)
        inst.Light:Enable(true)
    end
end

local function OnSave(inst, data)
    data.anim_index = inst.anim_index
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.anim_index ~= nil then
            inst.anim_index = data.anim_index
        end
    end
    CheckAnimAndLight(inst)
end

local function common_fn(anim_index)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.6)

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(43 / 255, 242 / 255, 31 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:Enable(true)

    inst.AnimState:SetBank("stariliad_necrons_crystal")
    inst.AnimState:SetBuild("stariliad_necrons_crystal")

    local s = 0.35
    inst.AnimState:SetScale(s, s, s)

    inst._light_mode = net_tinybyte(inst.GUID, "inst._light_mode", "light_mode_dirty")

    inst:ListenForEvent("light_mode_dirty", OnLightModeDirty)

    inst:SetPrefabName("stariliad_necrons_crystal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.anim_index = anim_index

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_necrons_crystal")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(MAX_WORKLEFT)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable.savestate = true

    CheckAnimAndLight(inst)

    return inst
end

local function fn()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn_1()
    local inst = common_fn(1)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn_2()
    local inst = common_fn(2)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn_3()
    local inst = common_fn(3)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


return Prefab("stariliad_necrons_crystal", fn, assets),
    Prefab("stariliad_necrons_crystal1", fn_1, assets),
    Prefab("stariliad_necrons_crystal2", fn_2, assets),
    Prefab("stariliad_necrons_crystal3", fn_3, assets)
