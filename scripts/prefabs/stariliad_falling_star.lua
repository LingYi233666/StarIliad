local assets = {
    Asset("ANIM", "anim/stariliad_falling_star.zip"),

    Asset("IMAGE", "images/inventoryimages/stariliad_falling_star.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_falling_star.xml"),
    Asset("IMAGE", "images/inventoryimages/stariliad_falling_star_cooked.tex"),
    Asset("ATLAS", "images/inventoryimages/stariliad_falling_star_cooked.xml"),
}

local FISH_DATA = require("prefabs/oceanfishdef")

local function OnCollide(inst, other)
    if not inst.hit_other then
        inst.hit_other = other
    end
end

local function DoAreaAttack(inst, addition_ents)
    local range = inst.components.combat:GetHitRange()
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range + 4, { "_combat", "_health" }, { "INLIMBO", "FX", "player" },
        { "monster", "hostile" })

    for _, v in pairs(ents) do
        if inst.components.combat:CanAttack(v) then
            inst.components.combat:DoAttack(v)
        end
    end

    if addition_ents then
        for _, v in pairs(addition_ents) do
            if inst.components.combat:CanTarget(v) then
                inst.components.combat:DoAttack(v)
            end
        end
    end
end

local function SpawnRandomFish(inst)
    local prefabs = {}
    for _, v in pairs(FISH_DATA.fish) do
        table.insert(prefabs, v.prefab)
    end

    local fish = SpawnAt(prefabs[math.random(#prefabs)], inst)
    -- fish.leaving = true
    fish.persists = false
    fish.Transform:SetRotation(math.random(-180, 180))
    fish.sg:GoToState("arrive")
end

local function DoFalling(inst, start_pos, target_pos)
    inst:EnableItemFX(false)

    if start_pos == nil then
        start_pos = inst:GetPosition() + Vector3FromTheta(math.random() * PI2, 6)
        start_pos.y = start_pos.y + 40
    end

    if target_pos == nil then
        target_pos = inst:GetPosition()
    end

    SpawnAt("stariliad_falling_star_falling_sound", target_pos)

    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem:SetSinks(false)

    -- local gravity = 18
    local height = start_pos.y - target_pos.y
    -- local duration = math.sqrt(height / (0.5 * gravity))

    local y_speed = -35
    local duration = height / math.abs(y_speed)

    local hor_velocity = (target_pos - start_pos)
    hor_velocity.y = y_speed
    hor_velocity = hor_velocity / duration

    inst.AnimState:PlayAnimation("falling", true)

    inst.Transform:SetPosition(start_pos:Get())
    -- inst.Physics:SetVel(hor_velocity:Get())

    inst.speed = hor_velocity
    inst.Physics:SetMotorVel(inst.speed:Get())

    inst.fx = inst:SpawnChild("stariliad_falling_star_fx")
    inst.task = inst:DoPeriodicTask(0, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        if y < 0.2 or inst.hit_other then
            inst.task:Cancel()
            inst.task = nil

            inst.fx:Remove()
            inst.fx = nil

            inst.AnimState:PlayAnimation("idle")
            inst.Physics:Stop()

            DoAreaAttack(inst, inst.hit_other and { inst.hit_other } or nil)

            inst:EnableItemFX(true)

            local hit_fx = SpawnAt("stariliad_falling_star_hit", inst)

            -- x, y, z, allow_boats
            if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
                inst.persists = false
                if math.random() < 0.5 then
                    SpawnRandomFish(inst)
                end
                SinkEntity(inst)
            else
                hit_fx:DoHitSound()

                inst.components.inventoryitem.canbepickedup = true
                inst.components.inventoryitem:SetSinks(true)

                local hit_vel = inst.speed
                hit_vel.y = 0
                hit_vel = hit_vel:GetNormalized() * GetRandomMinMax(2, 4)
                hit_vel = StarIliadMath.RotateVector3(hit_vel, Vector3(0, 1, 0), GetRandomMinMax(-10, 10))
                hit_vel.y = GetRandomMinMax(14, 18)
                inst.Physics:SetVel(hit_vel:Get())
            end
        else
            inst.Physics:SetMotorVel(inst.speed:Get())
            -- inst.speed.y = inst.speed.y - FRAMES * gravity
        end
    end)
end

local function EnableItemFX(inst, enable)
    local has_fx = inst.item_fx and inst.item_fx:IsValid()
    if enable and not has_fx then
        inst.item_fx = inst:SpawnChild("stariliad_falling_star_item_fx")
        inst.item_fx.entity:AddFollower()
        inst.item_fx.Follower:FollowSymbol(inst.GUID, "star", 0, 0, 0)
    elseif not enable and has_fx then
        inst.item_fx:Remove()
        inst.item_fx = nil
    end
end


local function OnPhase(inst)
    local phase = TheWorld.state.phase
    if phase ~= "dusk" and phase ~= "night" and inst.components.inventoryitem.owner == nil then
        inst.persists = false
        inst.components.inventoryitem.canbepickedup = false

        inst:DoTaskInTime(GetRandomMinMax(1, 1.5), function()
            SpawnAt("stariliad_falling_star_hit", inst)
            inst:Remove()
        end)
    end
end

local function OnDropped(inst)
    inst:EnableItemFX(true)
    OnPhase(inst)
end

local function OnPutInInventory(inst)
    inst:EnableItemFX(false)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_falling_star")
    inst.AnimState:SetBuild("stariliad_falling_star")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollide)

    inst.DoFalling = DoFalling
    inst.EnableItemFX = EnableItemFX

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetRange(1)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(1000)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_falling_star"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_falling_star.xml"
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 1
    inst.components.edible.sanityvalue = 0

    inst:AddComponent("cookable")
    inst.components.cookable.product = "stariliad_falling_star_cooked"

    inst:DoTaskInTime(0, OnPhase)

    inst:WatchWorldState("phase", OnPhase)

    inst:EnableItemFX(true)

    return inst
end


local function cooked_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_falling_star")
    inst.AnimState:SetBuild("stariliad_falling_star")
    inst.AnimState:PlayAnimation("idle_cooked")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "stariliad_falling_star_cooked"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/stariliad_falling_star_cooked.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 1
    inst.components.edible.hungervalue = 1
    inst.components.edible.sanityvalue = 1

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunch(inst)

    return inst
end

local function sound_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/falling_star/star_falling")
    end)

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

local function hit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fx = inst:SpawnChild("stariliad_falling_star_hit_fx")

    inst.DoHitSound = function()
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/falling_star/star_hit")
    end

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

-- c_spawn("stariliad_falling_star"):DoFalling()
return Prefab("stariliad_falling_star", fn, assets),
    Prefab("stariliad_falling_star_cooked", cooked_fn, assets),
    Prefab("stariliad_falling_star_falling_sound", sound_fn, assets),
    Prefab("stariliad_falling_star_hit", hit_fn, assets)
