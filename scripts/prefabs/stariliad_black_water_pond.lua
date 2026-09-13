require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/marsh_tile.zip"),
    Asset("ANIM", "anim/splash.zip"),
    Asset("ANIM", "anim/stariliad_black_water_pond.zip"),
}

local function SpawnPlants(inst)
    inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end

    if inst.plants == nil then
        inst.plants = {}
        for _ = 1, math.random(2, 4) do
            local theta = math.random() * TWOPI
            table.insert(inst.plants,
                {
                    offset =
                    {
                        math.sin(theta) * 1.9 + math.random() * .3,
                        0,
                        math.cos(theta) * 2.1 + math.random() * .3,
                    },
                })
        end
    end

    inst.plant_ents = {}

    for i, v in pairs(inst.plants) do
        if type(v.offset) == "table" and #v.offset == 3 then
            local plant = SpawnPrefab(inst.planttype)
            if plant ~= nil then
                plant.entity:SetParent(inst.entity)
                plant.Transform:SetPosition(unpack(v.offset))
                plant.persists = false
                table.insert(inst.plant_ents, plant)
            end
        end
    end
end

local function DespawnPlants(inst)
    if inst.plant_ents ~= nil then
        for i, v in ipairs(inst.plant_ents) do
            if v:IsValid() then
                v:Remove()
            end
        end

        inst.plant_ents = nil
    end

    inst.plants = nil
end

local function OnSave(inst, data)
    data.plants = inst.plants
end

local function OnLoad(inst, data)
    if data ~= nil then
        if inst.task ~= nil and inst.plants == nil then
            inst.plants = data.plants
        end
    end
end

local function PlayBubble(inst)
    if not inst.AnimState:IsCurrentAnimation("bubble_cave") then
        inst.AnimState:PlayAnimation("bubble_cave")
    end
    inst.AnimState:PushAnimation("idle_cave", true)
    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble")
end

local function PlaySplash(inst)
    if not inst.AnimState:IsCurrentAnimation("splash_cave") then
        inst.AnimState:PlayAnimation("splash_cave")
    end

    inst.AnimState:PushAnimation("idle_cave", true)
    -- inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
end

local duration = { 10, 20 }

local function PlayRandomAnim(inst)
    if math.random() < 0.7 then
        -- PlayBubble(inst)
    else
        PlaySplash(inst)
    end

    inst:DoTaskInTime(GetRandomMinMax(duration[1], duration[2]), PlayRandomAnim)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakePondPhysics(inst, 1.95)

    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:SetBuild("stariliad_black_water_pond")
    inst.AnimState:PlayAnimation("idle_cave", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    -- inst.MiniMapEntity:SetIcon("pond" .. pondtype .. ".png")

    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.no_wet_prefix = true

    inst:SetDeploySmartRadius(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("childspawner")

    inst:AddComponent("inspectable")
    -- inst.components.inspectable.nameoverride = "pond"

    inst:AddComponent("fishable")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
    inst.components.fishable:AddFish("stariliad_rock_trilobite")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("watersource")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:DoTaskInTime(GetRandomMinMax(duration[1], duration[2]), PlayRandomAnim)


    return inst
end



return Prefab("stariliad_black_water_pond", fn, assets)
