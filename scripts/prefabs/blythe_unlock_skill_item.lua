local assets = {
    Asset("ANIM", "anim/moonrock_seed.zip"),

}

local function MakeItem(skill_name, encrypted)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("moonrock_seed")
        inst.AnimState:SetBuild("moonrock_seed")
        inst.AnimState:PlayAnimation("idle")

        if encrypted then
            inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
        end

        MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

        if encrypted then
            inst:SetPrefabNameOverride("blythe_unlock_skill_item_encrypted")
        else
            inst:SetPrefabNameOverride("blythe_unlock_skill_item")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        StarIliadDebug.SetDebugInventoryImage(inst)

        inst:AddComponent("blythe_unlock_skill")
        inst.components.blythe_unlock_skill:SetSkillName(skill_name)
        inst.components.blythe_unlock_skill:SetEncrypted(encrypted)

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("blythe_unlock_skill_item_" .. skill_name, fn, assets)
end

local rets = {}
for _, data in pairs(BLYTHE_SKILL_DEFINES) do
    table.insert(rets, MakeItem(data.name, data.encrypted))
end

return unpack(rets)
