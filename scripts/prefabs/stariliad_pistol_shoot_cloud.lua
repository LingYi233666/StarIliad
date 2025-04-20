local assets = {}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("player_pistol")
    inst.AnimState:PlayAnimation("hand_shoot")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(17 * FRAMES)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("stariliad_pistol_shoot_cloud", fn, assets)
