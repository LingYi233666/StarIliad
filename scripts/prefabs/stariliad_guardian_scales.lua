local assets =
{
    Asset("ANIM", "anim/stariliad_guardian_scales.zip"),
    Asset("ANIM", "anim/bramblefx.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_guardian_scales.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_guardian_scales.xml"),
}

local function OnActive(inst, owner)
    inst._owner_attacked_callback = function(_, data)
        local fx = SpawnAt("stariliad_guardian_scales_fx", owner)

        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, owner:GetPhysicsRadius(0) + 2, nil, { "INLIMBO", "FX" })
        for k, v in pairs(ents) do
            if owner.components.combat and owner.components.combat:CanTarget(v) then
                v.components.combat:GetAttacked(owner, 0, nil, nil, {
                    planar = TUNING.STARILIAD_GUARDIAN_SCALES_DAMAGE,
                })
            end
        end
    end

    inst:ListenForEvent("attacked", inst._owner_attacked_callback, owner)
end

local function OnDeActive(inst, owner)
    inst:RemoveEventCallback("attacked", inst._owner_attacked_callback, owner)

    inst._owner_attacked_callback = nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_guardian_scales")
    inst.AnimState:SetBuild("stariliad_guardian_scales")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_guardian_scales"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_guardian_scales.xml"

    inst:AddComponent("stariliad_inventory_effect_item")
    inst.components.stariliad_inventory_effect_item:SetOnActivateFn(OnActive)
    inst.components.stariliad_inventory_effect_item:SetOnDeactivateFn(OnDeActive)

    MakeHauntableLaunch(inst)

    return inst
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bramblefx")
    inst.AnimState:SetBuild("bramblefx")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetMultColour(250 / 255, 167 / 255, 23 / 255, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false


    return inst
end


return Prefab("stariliad_guardian_scales", fn, assets),
    Prefab("stariliad_guardian_scales_fx", fxfn, assets)
