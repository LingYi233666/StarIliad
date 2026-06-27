local ROCK_ICE_STAGES = {
    "short",
    "medium",
    "tall",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:DoTaskInTime(1, function()
        local rock_ice = SpawnAt("rock_ice", inst)
        rock_ice.stage = GetRandomItem(ROCK_ICE_STAGES)

        inst:Remove()
    end)


    return inst
end

return Prefab("stariliad_placeholder_rock_ice", fn)
