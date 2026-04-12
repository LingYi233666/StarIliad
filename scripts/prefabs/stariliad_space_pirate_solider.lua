local assets =
{
    Asset("ANIM", "anim/antman_actions.zip"),
    Asset("ANIM", "anim/antman_attacks.zip"),
    Asset("ANIM", "anim/antman_basic.zip"),
    Asset("ANIM", "anim/antman_guard_build.zip"),
    Asset("ANIM", "anim/antman_translucent_build.zip"),
    Asset("ANIM", "anim/antman_warpaint_build.zip"),
}


local function lv2_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("antman")
    inst.AnimState:SetBuild("antman_guard_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("stariliad_space_pirate")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.can_charge = true

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("stariliad_space_pirate_solider_lv2", lv2_fn, assets)
