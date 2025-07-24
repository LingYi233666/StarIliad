local assets =
{
    Asset("ANIM", "anim/fountain_pillar.zip"),
}


SetSharedLootTable("stariliad_alien_ruins_pillar",
    {
        { "rocks", 1.00 },
        { "rocks", 1.00 },
        { "rocks", 1.00 },
        { "rocks", 0.25 },
        { "rocks", 0.25 },
    }
)

local function OnFinishCallback(inst, worker)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    inst.AnimState:PlayAnimation("pillar_collapse")
    inst.AnimState:PushAnimation("pillar_collapsed")
    inst.components.lootdropper:DropLoot()
end

local function OnLoadPostPass(inst, ents, data)
    if inst.components.workable.workleft <= 0 then
        inst.AnimState:PlayAnimation("pillar_collapsed")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("fountain_pillar")
    inst.AnimState:SetBank("fountain_pillar")
    inst.AnimState:PlayAnimation("pillar", true)

    -- inst.MiniMapEntity:SetIcon("pig_ruins_pillar.tex")

    inst.Transform:SetEightFaced()

    inst:AddTag("structure")

    MakeObstaclePhysics(inst, 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("savedrotation")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable.savestate = true
    inst.components.workable:SetOnFinishCallback(OnFinishCallback)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_alien_ruins_pillar")

    MakeHauntable(inst)

    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("stariliad_alien_ruins_pillar", fn, assets)
