local assets =
{
    Asset("ANIM", "anim/stariliad_energy_tank.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_energy_tank.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_energy_tank.xml"),
}

local function OnUse(inst, doer, num_to_remove)
    if doer == nil or doer.components.blythe_status_bonus == nil or doer.components.health == nil then
        return false
    end

    local addition = math.min(TUNING.BLYTHE_HEALTH_UPGRADE,
        TUNING.BLYTHE_HEALTH_THRESHOLD - doer.components.health.maxhealth)

    if addition > 0 then
        doer.components.blythe_status_bonus:AddBonus("health", addition)
    end

    doer.components.health:SetPercent(1)

    SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["energy_tank_health_update"], doer.userid)

    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_energy_tank")
    inst.AnimState:SetBuild("stariliad_energy_tank")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.2)
    -- MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    local scale = 1.3
    inst.AnimState:SetScale(scale, scale, scale)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_energy_tank"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_energy_tank.xml"

    inst:AddComponent("inspectable")

    inst:AddComponent("stariliad_useable_item")
    inst.components.stariliad_useable_item:SetOnUseFn(OnUse)

    return inst
end


return Prefab("stariliad_energy_tank", fn, assets)
