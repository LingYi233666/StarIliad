local function MakeItem(data)
    local prefab = "blythe_unlock_skill_item_" .. data.name
    local should_override_name = (STRINGS.NAMES[prefab:upper()] == nil)

    local tex_path = "images/inventoryimages/" .. prefab .. ".tex"
    local xml_path = "images/inventoryimages/" .. prefab .. ".xml"
    local has_special_inv_image = (resolvefilepath_soft(xml_path) ~= nil)

    if not has_special_inv_image then
        tex_path = "images/inventoryimages/stariliad_chozo_ability_ball.tex"
        xml_path = "images/inventoryimages/stariliad_chozo_ability_ball.xml"
    end

    local assets =
    {
        Asset("ANIM", "anim/moonrock_seed.zip"),
        Asset("ANIM", "anim/stariliad_chozo_ability_ball.zip"),

        Asset("IMAGE", tex_path),
        Asset("ATLAS", xml_path),

        Asset("IMAGE", "images/map_icons/stariliad_chozo_ability_ball.tex"), --小地图
        Asset("ATLAS", "images/map_icons/stariliad_chozo_ability_ball.xml"),
    }

    if data.build then
        table.insert(assets, Asset("ANIM", "anim/" .. data.build .. ".zip"))
    end

    if data.unique_map_icon then
        table.insert(assets, Asset("IMAGE", "images/map_icons/" .. prefab .. ".tex"))
        table.insert(assets, Asset("ATLAS", "images/map_icons/" .. prefab .. ".xml"))
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        if data.bank and data.build and data.anim then
            inst.AnimState:SetBank(data.bank)
            inst.AnimState:SetBuild(data.build)
            inst.AnimState:PlayAnimation(data.anim)
        else
            inst.AnimState:SetBank("stariliad_chozo_ability_ball")
            inst.AnimState:SetBuild("stariliad_chozo_ability_ball")
            inst.AnimState:PlayAnimation("idle")

            if data.encrypted then
                inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
            end
        end

        if data.unique_map_icon then
            inst.MiniMapEntity:SetIcon(prefab .. ".tex")
        else
            inst.MiniMapEntity:SetIcon("stariliad_chozo_ability_ball.tex")
        end

        -- MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

        if data.floater == nil then
            MakeInventoryFloatable(inst, "small", 0.3)
        elseif data.floater == false then

        else
            MakeInventoryFloatable(inst, unpack(data.floater))
        end

        if should_override_name then
            if data.encrypted then
                inst:SetPrefabNameOverride("blythe_unlock_skill_item_encrypted")
            else
                inst:SetPrefabNameOverride("blythe_unlock_skill_item")
            end
        end

        inst:AddTag("shoreonsink")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        if has_special_inv_image then
            inst.components.inventoryitem.imagename = prefab
        else
            inst.components.inventoryitem.imagename = "stariliad_chozo_ability_ball"
        end
        inst.components.inventoryitem.atlasname = xml_path

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
