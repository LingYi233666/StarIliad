local assets = {
    Asset("ANIM", "anim/slingshotammo.zip"),
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),
}

local function CreateAnim(bank, build, anim)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)

    return inst
end

local function explode_small_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    -- inst.AnimState:SetBank("slingshotammo")
    -- inst.AnimState:SetBuild("slingshotammo")
    -- inst.AnimState:PlayAnimation("used_gunpowder")
    -- -- inst.AnimState:SetSymbolAddColour("splode_round", 1, 1, 1, 1)
    -- inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)


    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst._anim = CreateAnim("slingshotammo", "slingshotammo", "used_gunpowder")
        inst._anim.AnimState:SetLightOverride(1)

        inst:AddChild(inst._anim)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0)
    end


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("stariliad_small_explode_particle")
    inst.vfx.entity:AddFollower()
    inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -150, 0)

    inst:DoTaskInTime(0, function()
        -- inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/gunpowder")
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/p1_explode")
        -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/missile_explode")
    end)

    inst:DoTaskInTime(2, inst.Remove)

    return inst
end


local function explode_small_blue_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst._anim = CreateAnim("missile_fx", "missile_fx", "impact")
        inst._anim.AnimState:SetLightOverride(1)

        inst:AddChild(inst._anim)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("stariliad_small_explode_blue_particle")
    inst.vfx.entity:AddFollower()
    inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)

    inst.sound_task = inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/p1_explode")
        -- inst.SoundEmitter:PlaySound("rifts5/wagstaff_boss/missile_explode")
    end)

    inst:DoTaskInTime(2, inst.Remove)

    return inst
end


local function explode_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_height_controller")
    inst.AnimState:SetBuild("stariliad_height_controller")
    inst.AnimState:PlayAnimation("no_face")

    inst.AnimState:SetMultColour(0, 0, 0, 0)

    if not TheNet:IsDedicated() then
        inst._anim = CreateAnim("lavaarena_firebomb", "lavaarena_firebomb", "used")
        inst._anim.AnimState:SetLightOverride(1)
        inst._anim.AnimState:SetAddColour(1, 1, 0, 1)

        inst:AddChild(inst._anim)

        inst._anim.entity:AddFollower()
        inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
    end

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("stariliad_normal_explode_particle")
    inst.vfx.entity:AddFollower()
    inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)

    inst:DoTaskInTime(0, function()
        -- inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/gunpowder")
        -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/explo_stereo")
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/explode")
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/active_grenade_fire")
    end)

    inst:DoTaskInTime(2, inst.Remove)

    return inst
end

return Prefab("blythe_missile_explode_fx", explode_small_fn, assets),
    Prefab("blythe_missile_explode_blue_fx", explode_small_blue_fn, assets),
    Prefab("blythe_super_missile_explode_fx", explode_fn, assets)
