local assets = {
    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),
}

local function KillFX(inst)
    inst.perish = true
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_loop")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst.AnimState:SetAddColour(0 / 255, 0 / 255, 255 / 255, 1)

    local s = 0.9
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.KillFX = KillFX

    inst:ListenForEvent("animover", function()
        if inst.perish then
            inst:Remove()
        else
            inst.AnimState:PlayAnimation("crackle_loop")
        end
    end)

    return inst
end

return Prefab("blythe_screw_attack_fx", fxfn, assets)
