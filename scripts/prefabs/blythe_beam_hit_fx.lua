local assets = {
    Asset("ANIM", "anim/deer_fire_charge.zip"),
    Asset("ANIM", "anim/deer_ice_charge.zip"),
}

local function CreateYellowAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetLightOverride(1)



    -- inst.AnimState:SetFinalOffset(data.final_offset)

    return inst
end

local function CreateBlueAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetLightOverride(1)


    -- inst.AnimState:SetFinalOffset(data.final_offset)

    return inst
end

local function yellow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst._anim = CreateYellowAnim()
        inst._anim.AnimState:SetScale(0.5, 0.5, 0.5)
        inst:AddChild(inst._anim)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/beam_hit")

    inst.particle = inst:SpawnChild("blythe_beam_hit_particle")
    inst.particle.entity:AddFollower()
    inst.particle.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)

    inst:DoTaskInTime(2, inst.Remove)

    return inst
end


local function purple_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst._anim = CreateBlueAnim()
        inst._anim.AnimState:SetScale(0.7, 0.7, 0.7)
        inst._anim.AnimState:SetAddColour(1, 0, 1, 1)

        inst:AddChild(inst._anim)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/beam_hit")


    inst:DoTaskInTime(2, inst.Remove)

    return inst
end


return Prefab("blythe_beam_yellow_hit_fx", yellow_fn, assets),
    Prefab("blythe_beam_purple_hit_fx", purple_fn, assets)
