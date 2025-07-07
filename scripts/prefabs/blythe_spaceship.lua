local assets =
{
    Asset("ANIM", "anim/blythe_spaceship.zip"),
}



-- c_spawn("blythe_spaceship"):StartCutscene(Vector3(-100, 100, 0), Vector3(0, 0, 0), 10)

local function StartCutscene(inst, start_pos, end_pos, duration)
    inst.sg:GoToState("cutscene1", {
        start_pos = start_pos,
        end_pos = end_pos,
        duration = duration,
    })
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)
    -- RemovePhysicsColliders(inst)
    -- MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blythe_spaceship")
    inst.AnimState:SetBuild("blythe_spaceship")
    inst.AnimState:SetPercent("idle_debug", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.velocity = nil

    inst.StartCutscene = StartCutscene

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGblythe_spaceship")

    return inst
end

return Prefab("blythe_spaceship", fn, assets)
