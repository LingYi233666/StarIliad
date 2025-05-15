local assets =
{
    Asset("ANIM", "anim/boat_water_fx2.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("boat_water_fx")
    inst.AnimState:SetBuild("boat_water_fx2")
    inst.AnimState:PlayAnimation("idle_loop_1")
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WAVES)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst:AddComponent("boattrailmover")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("stariliad_water_tail", fn, assets)
