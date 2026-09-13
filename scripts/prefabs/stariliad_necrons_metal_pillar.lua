local assets =
{
    Asset("ANIM", "anim/marble_pillar.zip"),
    Asset("ANIM", "anim/stariliad_necrons_metal_pillar2.zip"),
}

SetSharedLootTable('stariliad_necrons_metal_pillar',
    {
        { 'marble', 1.00 },
        { 'marble', 1.00 },
        { 'marble', 0.33 },
    }
)

local MAX_WORKLEFT = TUNING.MARBLEPILLAR_MINE

local function UpdateLightMode(inst)
    local workleft = inst.components.workable:GetWorkLeft()
    if workleft < MAX_WORKLEFT / 3 then
        inst._light_mode:set(0)
    elseif workleft < MAX_WORKLEFT * 2 / 3 then
        inst._light_mode:set(1)
    else
        inst._light_mode:set(2)
    end
end

local function OnWorked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
        inst.components.lootdropper:DropLoot(pos)
        inst:Remove()
    else
        UpdateLightMode(inst)

        inst.AnimState:PlayAnimation(
            (workleft < MAX_WORKLEFT / 3 and "low") or
            (workleft < MAX_WORKLEFT * 2 / 3 and "med") or
            "full"
        )
    end
end


local function OnLightModeDirty(inst)
    local val = inst._light_mode:value()
    if val == 0 then
        inst.Light:Enable(false)
    elseif val == 1 then
        inst.Light:SetRadius(1)
        inst.Light:Enable(true)
    elseif val == 2 then
        inst.Light:SetRadius(1.5)
        inst.Light:Enable(true)
    end
end

local function OnLoad(inst, data)
    UpdateLightMode(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("marble_pillar")
    inst.AnimState:SetBuild("stariliad_necrons_metal_pillar2")
    inst.AnimState:PlayAnimation("full")

    -- inst.MiniMapEntity:SetIcon("marblepillar.png")

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(43 / 255, 242 / 255, 31 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(1)
    inst.Light:Enable(true)

    MakeSnowCoveredPristine(inst)

    inst._light_mode = net_tinybyte(inst.GUID, "inst._light_mode", "light_mode_dirty")

    inst:ListenForEvent("light_mode_dirty", OnLightModeDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnLoad = OnLoad

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('stariliad_necrons_metal_pillar')

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(MAX_WORKLEFT)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    UpdateLightMode(inst)

    inst:DoTaskInTime(FRAMES, function()
        inst.green_parts = {
            inst:SpawnChild("stariliad_necrons_metal_pillar_green_part0"),
            inst:SpawnChild("stariliad_necrons_metal_pillar_green_part1"),
        }

        for _, v in pairs(inst.green_parts) do
            v.entity:AddFollower()

            v.components.highlightchild:SetOwner(inst)
            inst.components.colouradder:AttachChild(v)
        end

        inst.green_parts[1].Follower:FollowSymbol(inst.GUID, "marble_pillar01", nil, nil, nil, true, nil, 0)
        inst.green_parts[2].Follower:FollowSymbol(inst.GUID, "marble_pillar01", nil, nil, nil, true, nil, 1)
    end)

    return inst
end

local function MakeGreenPart(index)
    local function part_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("stariliad_necrons_metal_pillar2")
        inst.AnimState:SetBuild("stariliad_necrons_metal_pillar2")
        inst.AnimState:PlayAnimation("green_part" .. index)

        -- inst.AnimState:SetLightOverride(1)

        inst:AddTag("NOBLOCK")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:AddComponent("highlightchild")


        return inst
    end

    return Prefab("stariliad_necrons_metal_pillar_green_part" .. index, part_fn, assets)
end

return Prefab("stariliad_necrons_metal_pillar", fn, assets), MakeGreenPart(0), MakeGreenPart(1)
