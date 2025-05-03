local assets = {
    Asset("ANIM", "anim/deer_fire_charge.zip"),
    Asset("ANIM", "anim/deer_ice_charge.zip"),
    Asset("ANIM", "anim/laser_explode_sm.zip"),
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

    return inst
end

local function CreateRedAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("laser_explode_sm")
    inst.AnimState:SetBuild("laser_explode_sm")
    inst.AnimState:PlayAnimation("anim")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function yellow_anim_fn()
    local inst = CreateYellowAnim()
    inst.AnimState:SetScale(0.5, 0.5, 0.5)

    return inst
end

local function purple_anim_fn()
    local inst = CreateBlueAnim()
    -- inst.AnimState:SetScale(0.7, 0.7, 0.7)
    inst.AnimState:SetScale(0.5, 0.5, 0.5)

    inst.AnimState:SetAddColour(1, 0, 1, 1)

    return inst
end

local function green_anim_fn()
    local inst = CreateBlueAnim()
    -- inst.AnimState:SetScale(0.7, 0.7, 0.7)
    inst.AnimState:SetScale(0.5, 0.5, 0.5)

    inst.AnimState:SetMultColour(1, 1, 0.1, 1)
    inst.AnimState:SetAddColour(0, 1, 0, 1)

    return inst
end

local function red_anim_fn()
    local inst = CreateRedAnim()
    inst.AnimState:HideSymbol("sprks01")
    inst.AnimState:SetScale(0.5, 0.5, 0.5)
    -- inst.AnimState:SetAddColour(1, 1, 1, 1)

    return inst
end

local function white_anim_fn()
    local inst = CreateBlueAnim()
    inst.AnimState:SetScale(0.7, 0.7, 0.7)
    inst.AnimState:SetAddColour(1, 1, 1, 1)

    return inst
end

local function MakeHitFX(name, anim_fn, particle_prefab, particle_prefab2)
    local function fn()
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
            inst._anim = anim_fn()
            inst:AddChild(inst._anim)

            inst._anim.entity:AddFollower()
            inst._anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/blaster/beam_hit")

        if particle_prefab then
            inst.particle = inst:SpawnChild(particle_prefab)
            inst.particle.entity:AddFollower()
            inst.particle.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        if particle_prefab2 then
            inst.particle2 = inst:SpawnChild(particle_prefab2)
            inst.particle2.entity:AddFollower()
            inst.particle2.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -188, 0)
        end

        inst:DoTaskInTime(2, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeHitFX("blythe_beam_yellow_hit_fx", yellow_anim_fn, "blythe_beam_hit_particle"),
    MakeHitFX("blythe_beam_purple_hit_fx", purple_anim_fn, "blythe_beam_hit_particle_purple"),
    MakeHitFX("blythe_beam_green_hit_fx", green_anim_fn, "blythe_beam_hit_particle_green"),
    MakeHitFX("blythe_beam_green_purple_hit_fx", green_anim_fn, "blythe_beam_hit_particle_green_half",
        "blythe_beam_hit_particle_purple_half"),
    MakeHitFX("blythe_beam_red_hit_fx", red_anim_fn, "blythe_beam_hit_particle_red"),
    MakeHitFX("blythe_beam_white_hit_fx", white_anim_fn, "blythe_beam_hit_particle_blue")
