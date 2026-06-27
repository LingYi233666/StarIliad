local assets =
{
    Asset("ANIM", "anim/laser_ring_fx.zip"),
}

local function Scorch_OnUpdateFade(inst)
    inst.alpha = math.max(0, inst.alpha - (1 / 90))
    inst.AnimState:SetMultColour(1, 1, 1, inst.alpha)
    if inst.alpha == 0 then
        inst:Remove()
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("laser_ring_fx")
    inst.AnimState:SetBank("laser_ring_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetSymbolLightOverride("circle", 1)
    inst.AnimState:SetSymbolLightOverride("glow_2", 1)
    inst.AnimState:SetSymbolLightOverride("lightning01", 1)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    -- inst.Transform:SetScale(0.85, 0.85, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.alpha = 1
    inst:DoTaskInTime(0.7, function()
        inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    end)

    inst.Transform:SetRotation(math.random() * 360)

    return inst
end

return Prefab("stariliad_laser_ring", scorchfn, assets)
