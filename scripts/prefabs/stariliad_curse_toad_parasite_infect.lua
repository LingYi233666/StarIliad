local assets =
{
    Asset("IMAGE", "images/inventoryimages/stariliad_curse_toad_parasite_infect.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_curse_toad_parasite_infect.xml"),
}

local function OnActive(inst, owner)
    inst._damage_task = inst:DoPeriodicTask(1, function()
        if owner.components.health and not IsEntityDeadOrGhost(owner, true) then
            local factor = inst.components.stackable and inst.components.stackable:StackSize() or 1
            owner.components.health:DoDelta(-TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_EMIT_WORMS_DAMAGE_CURSE * factor,
                true, inst.prefab)
        end
    end)
end

local function OnDeActive(inst, owner)
    if inst._damage_task then
        inst._damage_task:Cancel()
    end
    inst._damage_task = nil
end


local function OnUse(inst, user)
    if user and user:IsValid() and user.SoundEmitter then
        user.SoundEmitter:PlaySound("stariliad_sfx/prefabs/toad_parasite/attack")
    end

    local worms_fx = SpawnAt("stariliad_boss_toad_parasite_worms_fx", user)

    return true
end

local function OnDropped(inst)
    if inst.remove_task then
        inst.remove_task:Cancel()
        inst.remove_task = nil
    end

    inst.remove_task = inst:DoTaskInTime(1, function()
        inst:Remove()
    end)
end

local function OnPutInInventory(inst)
    if inst.remove_task then
        inst.remove_task:Cancel()
        inst.remove_task = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("nosteal")
    inst:AddTag("cursed")

    inst.stariliad_useable_item_str = "TOAD_PARASITE_INFECT"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_curse_toad_parasite_infect"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_curse_toad_parasite_infect.xml"
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem.keepondrown = true

    inst:AddComponent("inspectable")

    inst:AddComponent("curseditem")
    inst.components.curseditem.curse = "STARILIAD_CURSE_TOAD_PARASITE_INFECT"

    inst:AddComponent("stariliad_inventory_effect_item")
    inst.components.stariliad_inventory_effect_item:SetOnActivateFn(OnActive)
    inst.components.stariliad_inventory_effect_item:SetOnDeactivateFn(OnDeActive)

    inst:AddComponent("stariliad_useable_item")
    inst.components.stariliad_useable_item:SetMaxRemoveSize(1)
    inst.components.stariliad_useable_item:SetActionDuration(1)
    inst.components.stariliad_useable_item:SetUseActionMeter(true)
    inst.components.stariliad_useable_item:SetOnUseFn(OnUse)

    inst:ListenForEvent("ondropped", OnDropped)
    inst:ListenForEvent("onputininventory", OnPutInInventory)

    inst.remove_task = inst:DoTaskInTime(1, function()
        if inst.components.inventoryitem.owner == nil then
            inst:Remove()
        end
    end)

    return inst
end


return Prefab("stariliad_curse_toad_parasite_infect", fn, assets)
