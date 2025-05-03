local assets = {
    Asset("ANIM", "anim/blythe.zip"),
}


local function CommonFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    RemovePhysicsColliders(inst)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetFourFaced(inst)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("blythe")
    inst.AnimState:PlayAnimation("idle")


    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")

    -- inst.AnimState:SetMultColour(0, 0, 0, .5)
    -- inst.AnimState:SetAddColour(0, 0, 0.8, 1)
    inst.AnimState:UsePointFiltering(true)

    inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    inst.Copy = function(inst, owner)
        inst.owner = owner
        inst.components.skinner:CopySkinsFromPlayer(owner)
    end

    inst.FadeOut = function(inst, duration)
        local r, g, b, a = inst.AnimState:GetMultColour()
        local a_speed = a / duration

        inst:DoPeriodicTask(0, function()
            a = math.max(0, a - a_speed * FRAMES)
            inst.AnimState:SetMultColour(r, g, b, a)
        end)
        inst:DoTaskInTime(duration, inst.Remove)
    end

    return inst
end

local function NormalCloneFn()
    local inst = CommonFn()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


return Prefab("blythe_clone", NormalCloneFn, assets)
