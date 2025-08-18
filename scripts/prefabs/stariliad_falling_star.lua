local assets = {
    Asset("ANIM", "anim/stariliad_falling_star.zip"),
}

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

local function OnPhase(inst)
    if not (TheWorld.state.isdusk or TheWorld.state.isnight) and inst.components.inventoryitem.owner == nil then
        inst.persists = false
        inst.components.inventoryitem.canbepickedup = false

        inst:DoTaskInTime(math.random() * 1.5, function()
            SpawnAt("stariliad_falling_star_hit", inst).sound_task:Cancel()
            inst:Remove()
        end)
    end
end

local function DoFalling(inst, start_pos, target_pos)
    if start_pos == nil then
        start_pos = inst:GetPosition() + Vector3FromTheta(math.random() * PI2, 6)
        start_pos.y = start_pos.y + 40
    end

    if target_pos == nil then
        target_pos = inst:GetPosition()
    end

    SpawnAt("stariliad_falling_star_falling_sound", target_pos)

    inst.components.inventoryitem.canbepickedup = false


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
            inst.fx:Remove()
            inst.fx = nil

            inst.AnimState:PlayAnimation("idle")
            inst.Physics:Stop()

            DoAreaAttack(inst, inst.hit_other and { inst.hit_other } or nil)

            SpawnAt("stariliad_falling_star_hit", inst)

            local hit_vel = inst.speed
            hit_vel.y = 0
            hit_vel = hit_vel:GetNormalized() * GetRandomMinMax(2, 4)
            hit_vel = StarIliadMath.RotateVector3(hit_vel, Vector3(0, 1, 0), GetRandomMinMax(-10, 10))
            hit_vel.y = GetRandomMinMax(14, 18)
            inst.Physics:SetVel(hit_vel:Get())


            inst.components.inventoryitem.canbepickedup = true


            inst.task:Cancel()
            inst.task = nil
        else
            inst.Physics:SetMotorVel(inst.speed:Get())
            -- inst.speed.y = inst.speed.y - FRAMES * gravity
        end
    end)
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

    local s = 1.66
    inst.AnimState:SetScale(s, s, s)

    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollide)

    inst.DoFalling = DoFalling

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetRange(1)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(1000)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem:SetOnDroppedFn(OnPhase)
    StarIliadDebug.SetDebugInventoryImage(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GENERIC
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 1
    inst.components.edible.sanityvalue = 0

    inst:DoTaskInTime(0, OnPhase)

    inst:WatchWorldState("phase", OnPhase)

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
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetMultColour(0.4, 0.4, 0.4, 1)

    local s = 1.66
    inst.AnimState:SetScale(s, s, s)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem:SetOnDroppedFn(OnPhase)
    StarIliadDebug.SetDebugInventoryImage(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GENERIC
    inst.components.edible.healthvalue = 1
    inst.components.edible.hungervalue = 1
    inst.components.edible.sanityvalue = 1

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

    inst.sound_task = inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/falling_star/star_hit")
    end)

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

-- c_spawn("stariliad_falling_star"):DoFalling()
return Prefab("stariliad_falling_star", fn, assets),
    Prefab("stariliad_falling_star_cooked", fn, assets),
    Prefab("stariliad_falling_star_falling_sound", sound_fn, assets),
    Prefab("stariliad_falling_star_hit", hit_fn, assets)
