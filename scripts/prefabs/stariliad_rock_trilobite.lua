local assets =
{
    Asset("ANIM", "anim/stariliad_rock_trilobite.zip"),
    -- Asset("ANIM", "anim/swap_stariliad_rock_trilobite.zip"),
    Asset("ANIM", "anim/fish01.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_rock_trilobite.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_rock_trilobite.xml"),
}

SetSharedLootTable("stariliad_rock_trilobite",
    {
        { "rocks",          1.00 },
        { "rocks",          0.5 },
        { "fishmeat_small", 1.0 },
        { "fishmeat_small", 0.75 },
    }
)

local function OnMine(inst, miner, workleft, workdone)
    -- local loots = {
    --     SpawnAt("rocks", inst),
    --     SpawnAt("fishmeat", inst),
    -- }

    -- if math.random() <= 0.5 then
    --     table.insert(loots, SpawnAt("rocks", inst))
    -- end

    -- if math.random() <= 0.2 then
    --     table.insert(loots, SpawnAt("fishmeat", inst))
    -- end

    -- for _, loot in pairs(loots) do
    --     LaunchAt(loot, inst, miner, -1.8, 1.33, nil, 65)
    -- end

    if workleft <= 0 then
        SpawnAt("rock_break_fx", inst)

        inst.components.lootdropper:DropLoot()
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_rock_trilobite")
    inst.AnimState:SetBuild("stariliad_rock_trilobite")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("fish")
    inst:AddTag("pondfish")
    inst:AddTag("smallcreature")
    inst:AddTag("show_spoilage")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.build = "stariliad_rock_trilobite" --This is used within SGwilson, sent from an event in fishingrod.lua

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_rock_trilobite"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_rock_trilobite.xml"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_rock_trilobite")

    -- inst:AddComponent("stackable")
    -- inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    -- inst:AddComponent("bait")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "rocks"

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(OnMine)

    -- if dryable then
    --     inst:AddComponent("dryable")
    --     inst.components.dryable:SetProduct("fishmeat_small_dried")
    --     inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    --     inst.components.dryable:SetDriedBuildFile("meat_rack_food_tot")
    -- end


    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

return Prefab("stariliad_rock_trilobite", fn, assets)
