local assets =
{
    Asset("ANIM", "anim/farm_plant_tomato.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
    Asset("ANIM", "anim/blythe_skill_heal.zip"),


    Asset("SCRIPT", "scripts/prefabs/farm_plant_defs.lua"),
    Asset("SCRIPT", "scripts/prefabs/weed_defs.lua"),
}

local function DropHeart(inst)

end

-- local function OnAnimOver(inst)

-- end

local function plant_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("farm_plant_tomato")
    inst.AnimState:SetBuild("farm_plant_tomato")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

    -----------------------------------------------------------------------
    -- inst.AnimState:PlayAnimation("sow", false)
    -- inst.AnimState:PushAnimation("sow_idle", true)

    -- local anims = {
    --     "seed",
    --     "sprout",
    --     "small",
    --     "med",
    --     "full",
    -- }

    -- for _, v in pairs(anims) do
    --     inst.AnimState:PlayAnimation("grow_" .. v, false)
    --     inst.AnimState:PushAnimation("crop_" .. v, true)
    -- end

    inst.AnimState:PlayAnimation("sow")
    inst.AnimState:PushAnimation("grow_seed", false)
    inst.AnimState:PushAnimation("grow_sprout", false)
    inst.AnimState:PushAnimation("grow_small", false)
    inst.AnimState:PushAnimation("grow_med", false)
    inst.AnimState:PushAnimation("grow_full", false)
    inst.AnimState:PushAnimation("crop_full", true)



    inst:AddTag("plant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists    = false

    inst.heal_amount = 99
    inst.heal_range  = 10

    inst:AddComponent("inspectable")

    -- MakeSmallBurnable(inst)
    -- MakeSmallPropagator(inst)
    -- inst.components.burnable:SetOnBurntFn(onburnt)
    -- inst.components.burnable:SetOnIgniteFn(onignite)
    -- inst.components.burnable:SetOnExtinguishFn(onextinguish)

    -- inst:DoTaskInTime(10, DropHeart)

    -- inst:ListenForEvent("animover", OnAnimOver)

    return inst
end

local function heart_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("blythe_skill_heal")
    inst.AnimState:SetBuild("blythe_skill_heal")
    inst.AnimState:PlayAnimation("heart", true)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists    = false

    inst.heal_amount = 99
    inst.heal_range  = 10



    return inst
end

return Prefab("blythe_heal_heart_plant", plant_fn, assets),
    Prefab("blythe_heal_heart", heart_fn, assets)
