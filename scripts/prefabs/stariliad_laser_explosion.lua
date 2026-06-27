local assets =
{
    Asset("ANIM", "anim/laser_explosion.zip"),
}

local function explosionfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("laser_explosion")
    inst.AnimState:SetBank("laser_explosion")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    -- inst.Transform:SetScale(0.85, 0.85, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("stariliad_laser_explosion", explosionfn, assets)
