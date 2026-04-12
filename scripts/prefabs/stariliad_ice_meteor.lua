local assets =
{
    Asset("ANIM", "anim/stariliad_lava_meteor.zip"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_lava_meteor")
    inst.AnimState:SetBuild("stariliad_lava_meteor")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end




    return inst
end

return Prefab("stariliad_ice_meteor", fn, assets)
