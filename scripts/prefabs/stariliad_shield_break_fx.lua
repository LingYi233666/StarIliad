local assets = {
    Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("beetletaur_break")
    inst.AnimState:SetBuild("lavaarena_beetletaur_break")
    inst.AnimState:PlayAnimation("anim")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    local s = 0.33
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("stariliad_shield_break_fx", fn, assets)
