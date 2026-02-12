local assets =
{
    Asset("ANIM", "anim/blythe_backpack.zip"),

    Asset("IMAGE", "images/inventoryimages/blythe_backpack.tex"),
    Asset("ATLAS", "images/inventoryimages/blythe_backpack.xml"),

    Asset("IMAGE", "images/map_icons/blythe_backpack.tex"), --小地图
    Asset("ATLAS", "images/map_icons/blythe_backpack.xml"),
}

---------------------------------------------------------------------------------------
local backpack_params =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(-5, -80, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 3 do
    table.insert(backpack_params.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(backpack_params.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

-- local slotpos_preset = {}
-- for y = 0, 6 do
--     table.insert(slotpos_preset, Vector3(-162, -75 * y + 240, 0))
--     table.insert(slotpos_preset, Vector3(-162 + 75, -75 * y + 240, 0))
-- end

StarIliadBasic.AddContainersParams("blythe_backpack", backpack_params)

---------------------------------------------------------------------------------------

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "blythe_backpack", "swap_body")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blythe_backpack")
    inst.AnimState:SetBuild("blythe_backpack")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("backpack")

    inst.MiniMapEntity:SetIcon("blythe_backpack.tex")

    -- inst.foleysound = "dontstarve/movement/foley/backpack"
    inst.foleysound = "dontstarve/movement/foley/metalarmour"

    local swap_data = { bank = "blythe_backpack", anim = "idle" }
    MakeInventoryFloatable(inst, "small", 0.2, nil, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "blythe_backpack"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blythe_backpack.xml"
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("blythe_backpack")

    -- inst:AddComponent("preserver")
    -- inst.components.preserver:SetPerishRateMultiplier(0.5)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end


return Prefab("blythe_backpack", fn, assets)
