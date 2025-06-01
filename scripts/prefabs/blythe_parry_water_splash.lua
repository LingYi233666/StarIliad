local assets = {

}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("Bubble_fx")
    inst.AnimState:SetBuild("crab_king_bubble_fx")
    inst.AnimState:PlayAnimation("waterspout")

    inst.AnimState:SetFinalOffset(1)

    local s = 0.66
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/waterspout", nil, 0.5)

    return inst
end

return Prefab("blythe_parry_water_splash", fn, assets)
