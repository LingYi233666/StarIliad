local assets =
{
    Asset("ANIM", "anim/weevole.zip"),
    Asset("ANIM", "anim/stariliad_necrons_scarab.zip"),
}

SetSharedLootTable("stariliad_necrons_scarab",
    {
        { 'monstermeat', 1.0 },
    }
)

local function RetargetFn(inst)
    local notags = { "FX", "NOCLICK", "INLIMBO", "wall", "stariliad_necrons", "structure", "aquatic" }
    return FindEntity(inst, 10, function(guy)
        return inst.components.combat:CanTarget(guy)
    end, nil, notags)
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30,
        function(dude)
            return dude:HasTag("stariliad_necrons") and not dude.components.health:IsDead()
        end,
        10)
end

local function OnFlyIn(inst)
    inst.DynamicShadow:Enable(false)
    inst.components.health:SetInvincible(true)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Transform:SetPosition(x, 15, z)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(43 / 255, 242 / 255, 31 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(0.67)
    inst.Light:Enable(true)

    inst.DynamicShadow:SetSize(1.5, .5)
    inst.Transform:SetSixFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("mech")
    inst:AddTag("hostile")
    inst:AddTag("smallcreature")
    inst:AddTag("stariliad_necrons")

    inst.AnimState:SetBank("weevole")
    inst.AnimState:SetBuild("stariliad_necrons_scarab")
    inst.AnimState:PlayAnimation("idle")

    local scale = 1.3
    inst.Transform:SetScale(scale, scale, scale)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 5

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_necrons_scarab")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(250)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetDefaultDamage(20)
    inst.components.combat:SetAttackPeriod(GetRandomMinMax(4, 5))
    inst.components.combat:SetRange(5, 1.5)
    inst.components.combat:SetHurtSound("dontstarve/impacts/impact_mech_med_sharp")

    inst:AddComponent("knownlocations")

    inst:AddComponent("updatelooper")

    inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.ELEMENTAL }, { FOODTYPE.ELEMENTAL })


    inst.stariliad_movement_dust_necrons_tomb = inst:SpawnChild("stariliad_movement_dust_necrons_tomb")


    MakeSmallBurnableCharacter(inst, "body")
    MakeSmallFreezableCharacter(inst, "body")

    local brain = require "brains/stariliad_necrons_scarab_brain"

    inst:SetStateGraph("SGstariliad_necrons_scarab")
    inst:SetBrain(brain)

    -- inst:ListenForEvent("fly_in", OnFlyIn) -- matches enter_loop logic so it does not happen a frame late
    inst:ListenForEvent("attacked", OnAttacked)



    return inst
end

----------------------------------------------------------------------------------------

local function ChildSpawnedFn(inst, child)
    child.sg:GoToState("emerge")
end

local function HomeAlwaysUpdate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, nil, { "FX", "INLIMBO", "NOCLICK" }, { "character", "largecreature" })
    local should_spawn = false

    for _, v in ipairs(ents) do
        if not IsEntityDeadOrGhost(v, true) then
            should_spawn = true
            break
        end
    end

    if should_spawn and not inst.components.childspawner.spawning then
        inst.components.childspawner:StartSpawning()
    elseif not should_spawn and inst.components.childspawner.spawning then
        inst.components.childspawner:StopSpawning()
    end
end

local function HomeAlwaysEntityWake(inst)
    if not inst.task then
        inst.task = inst:DoPeriodicTask(5, HomeAlwaysUpdate)
    end
end

local function HomeAlwaysEntitySleep(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.childspawner:StopSpawning()
end

local function HomeCommon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "stariliad_necrons_scarab"
    inst.components.childspawner.spawnradius = TUNING.STARILIAD_NECRONS_SCARAB_HOME_SPAWN_RADIUS
    inst.components.childspawner:SetSpawnPeriod(TUNING.STARILIAD_NECRONS_SCARAB_HOME_SPAWN_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.STARILIAD_NECRONS_SCARAB_HOME_REGEN_TIME)
    inst.components.childspawner:SetMaxChildren(math.random(unpack(TUNING.STARILIAD_NECRONS_SCARAB_HOME_NUM_CHILDREN)))
    inst.components.childspawner:SetSpawnedFn(ChildSpawnedFn)
    inst.components.childspawner:StartRegen()

    return inst
end

local function home_always_fn()
    local inst = HomeCommon()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.childspawner:StartSpawning()

    return inst
end

local function home_nearby_fn()
    local inst = HomeCommon()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, function()
        if not inst:IsAsleep() then
            inst.task = inst:DoPeriodicTask(5, HomeAlwaysUpdate)
        end
    end)

    inst.OnEntityWake = HomeAlwaysEntityWake
    inst.OnEntitySleep = HomeAlwaysEntitySleep

    return inst
end

return Prefab("stariliad_necrons_scarab", fn, assets),
    Prefab("stariliad_necrons_scarab_home_always", home_always_fn),
    Prefab("stariliad_necrons_scarab_home_nearby", home_nearby_fn)
