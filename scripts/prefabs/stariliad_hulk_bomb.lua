local assets =
{
    Asset("ANIM", "anim/metal_hulk_bomb.zip"),
}


local LIGHT_DATA =
{
    Vector3(.1, 1, .1),
    Vector3(1, .1, .1),
}

local function OnLightDataDirty(inst)
    local light_data = LIGHT_DATA[inst._light_data:value()]

    if light_data then
        inst.Light:SetColour(light_data.x, light_data.y, light_data.z)
        inst.Light:Enable(true)
    else
        inst.Light:Enable(false)
    end
end

local function placed_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.Light:SetFalloff(0.3)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(0.5)
    -- inst.Light:SetColour(lightdata.colour.x, lightdata.colour.y, lightdata.colour.z)
    inst.Light:Enable(false)

    inst.AnimState:SetBank("metal_hulk_mine")
    inst.AnimState:SetBuild("metal_hulk_bomb")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("stariliad_hulk_bomb")

    inst._light_data = net_tinybyte(inst.GUID, "inst._light_data", "lightdatadirty")
    inst._light_data:set(0)

    inst:ListenForEvent("lightdatadirty", OnLightDataDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(100)

    inst:SetStateGraph("SGstariliad_hulk_bomb_placed")

    return inst
end

local function player_placed_fn()
    local inst = placed_fn()

    inst:SetPrefabNameOverride("stariliad_hulk_bomb_placed")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.player_placed = true

    return inst
end


return Prefab("stariliad_hulk_bomb_placed", placed_fn, assets),
    Prefab("stariliad_hulk_bomb_player_placed", player_placed_fn, assets)
