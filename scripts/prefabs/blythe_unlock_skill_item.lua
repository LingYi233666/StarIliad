local function MakeItem(data)
    local prefab = "blythe_unlock_skill_item_" .. data.name
    local should_override_name = (STRINGS.NAMES[prefab:upper()] == nil)
    local xml_path = "images/inventoryimages/" .. prefab .. ".xml"
    local has_inventoryimage = (resolvefilepath_soft(xml_path) ~= nil)

    local assets =
    {
        Asset("ANIM", "anim/moonrock_seed.zip"),
    }

    if has_inventoryimage then
        table.insert(assets, Asset("IMAGE", "images/inventoryimages/" .. prefab .. ".tex"))
        table.insert(assets, Asset("ATLAS", xml_path))
    end

    if data.build then
        table.insert(assets, Asset("ANIM", "anim/" .. data.build .. ".zip"))
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        if data.bank and data.build and data.anim then
            inst.AnimState:SetBank(data.bank)
            inst.AnimState:SetBuild(data.build)
            inst.AnimState:PlayAnimation(data.anim)
        else
            inst.AnimState:SetBank("moonrock_seed")
            inst.AnimState:SetBuild("moonrock_seed")
            inst.AnimState:PlayAnimation("idle")

            if data.encrypted then
                inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
            end
        end

        MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

        if should_override_name then
            if data.encrypted then
                inst:SetPrefabNameOverride("blythe_unlock_skill_item_encrypted")
            else
                inst:SetPrefabNameOverride("blythe_unlock_skill_item")
            end
        end


        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        if has_inventoryimage then
            inst.components.inventoryitem.imagename = prefab
            inst.components.inventoryitem.atlasname = xml_path
        else
            StarIliadDebug.SetDebugInventoryImage(inst)
        end

        if data.stack_size then
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = data.stack_size
        end

        inst:AddComponent("blythe_unlock_skill")
        inst.components.blythe_unlock_skill:SetSkillName(data.name)
        inst.components.blythe_unlock_skill:SetEncrypted(data.encrypted)
        inst.components.blythe_unlock_skill:SetTeachOverrideFn(data.teach_override)

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(prefab, fn, assets)
end

local rets = {}
for _, data in pairs(BLYTHE_SKILL_DEFINES) do
    -- table.insert(rets, MakeItem(data.name, data.encrypted, data.stack_size, data.teach_override))
    if not data.root then
        table.insert(rets, MakeItem(data))
    end
end

return unpack(rets)
