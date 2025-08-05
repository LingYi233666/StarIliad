local assets = {

}

local function OnIgnite(inst, data)
    if not (inst.fire and inst.fire:IsValid()) then
        inst.fire = inst:SpawnChild("torchfire")
        inst.fire.entity:AddFollower()
        inst.fire.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)

        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end
end

local function OnExtinguish(inst, data)
    if inst.fire and inst.fire:IsValid() then
        inst.fire:Remove()
        -- inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    end
    inst.fire = nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.anim = inst:SpawnChild("stariliad_hexa_ball_anim")
    inst.anim.entity:AddFollower()
    inst.anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)

    inst:ListenForEvent("stariliad_hexa_ignite", OnIgnite)
    inst:ListenForEvent("stariliad_hexa_extinguish", OnExtinguish)

    return inst
end

local function anim_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rocks")
    inst.AnimState:SetBuild("rocks")
    inst.AnimState:PlayAnimation("f1")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("stariliad_hexa_ball", fn, assets),
    Prefab("stariliad_hexa_ball_anim", anim_fn, assets)
