local assets =
{
    Asset("ANIM", "anim/blythe_ship.zip"),

    Asset("IMAGE", "images/map_icons/blythe_ship.tex"), --小地图
    Asset("ATLAS", "images/map_icons/blythe_ship.xml"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blythe_ship")
    inst.AnimState:SetBuild("blythe_ship")
    inst.AnimState:PlayAnimation("idle_broken2")

    local s = 1.3
    inst.AnimState:SetScale(s, s, s)

    MakeObstaclePhysics(inst, 1.2)

    inst.MiniMapEntity:SetIcon("blythe_ship.tex")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    TheWorld.blythe_ship = inst

    return inst
end

return Prefab("blythe_ship", fn, assets)
