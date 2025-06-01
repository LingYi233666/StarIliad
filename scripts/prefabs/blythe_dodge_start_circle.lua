local assets =
{
    Asset("ANIM", "anim/bearger_ring_fx.zip"),
}


local function CreateAnim()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("bearger_ring_fx")
    inst.AnimState:SetBuild("bearger_ring_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFrame(5)
    -- inst.AnimState:SetDeltaTimeMultiplier(0.8)
    inst.AnimState:SetMultColour(100 / 255, 230 / 255, 230 / 255, 1)
    -- inst.AnimState:SetAddColour(0 / 255, 230 / 255, 230 / 255, 1)

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetFinalOffset(1)

    local s = 0.28
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)


    return inst
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

    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()

        inst._anim = CreateAnim()
        inst:AddChild(inst._anim)
        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)

        -- client side sound
        inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/dodge", nil, nil, true)
    end


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("blythe_dodge_start_circle", fn, assets)
