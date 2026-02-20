local assets =
{
    Asset("ANIM", "anim/spider_queen_build.zip"),
    Asset("ANIM", "anim/spider_queen.zip"),
    Asset("ANIM", "anim/spider_queen_2.zip"),
    --Asset("ANIM", "anim/spider_queen_3.zip"),
    --Asset("SOUND", "sound/spider.fsb"),
}

SetSharedLootTable("stariliad_boss_spyder",
    {
        { "blythe_unlock_skill_item_speed_burst", 1.0 },

        { "greengem",                             1.0 },
        { "greengem",                             1.0 },
        { "greengem",                             1.0 },
    }
)

local function RetargetFn(inst)
    if inst.components.health:IsDead() then
        return
    end

    return FindEntity(inst, 10,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat" },
        { "necron", "INLIMBO" },
        { "character", "player", "monster" }
    )
end


local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        inst.components.combat:SetTarget(data.attacker)
    end
end

local function OnNewCombatTarget(inst, data)
    if inst.components.health:IsDead() then
        return
    end

    if inst.loss_target_task then
        inst.loss_target_task:Cancel()
        inst.loss_target_task = nil
    end

    inst:SetMusicLevel(2)
end

local function OnDroppedTarget(inst, data)
    if inst.loss_target_task then
        inst.loss_target_task:Cancel()
    end

    inst.loss_target_task = inst:DoTaskInTime(5, function()
        inst:SetMusicLevel(1)
        inst.loss_target_task = nil
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, 1)

    inst.DynamicShadow:SetSize(7, 3)
    inst.Transform:SetFourFaced()

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("largecreature")
    inst:AddTag("necron") -- 太空死灵种族

    inst.AnimState:SetBank("spider_queen")
    inst.AnimState:SetBuild("spider_queen_build")
    inst.AnimState:PlayAnimation("idle", true)

    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_spyder")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.override_combat_fx_size = "med"

    inst:AddComponent("entitytracker")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_boss_spyder")

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_BOSS_SPYDER_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.STARILIAD_BOSS_SPYDER_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_SPYDER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_SPYDER_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)

    ------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    ------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier(1)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.STARILIAD_BOSS_SPYDER_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.STARILIAD_BOSS_SPYDER_RUNSPEED

    ------------------

    inst:AddComponent("inspectable")

    ------------------

    local brain = require "brains/stariliad_boss_spyder_brain"
    inst:SetStateGraph("SGstariliad_boss_spyder")
    inst:SetBrain(brain)

    -- inst.hit_recovery = TUNING.SPIDERQEEN_HIT_RECOVERY
    -- inst.spawn_lunar_mutated_tuning = "SPAWN_MUTATED_SPIDERQUEEN"

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    return inst
end

local function spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("spawner")
    inst.components.spawner:Configure("stariliad_boss_spyder", TUNING.TOTAL_DAY_TIME * 100)
    inst.components.spawner:SetOnlySpawnOffscreen(true)
    inst.components.spawner:SetOnSpawnedFn(function(inst, child)
        child.components.entitytracker:TrackEntity("spawner", inst)
    end)

    inst.components.spawner:SetOnVacateFn(function(inst, child)
        -- local mid_radius = (TUNING.STARILIAD_BOSS_SPYDER_CHARGE_MIN_RADIUS + TUNING.STARILIAD_BOSS_SPYDER_CHARGE_MAX_RADIUS) /
        --     2

        local mid_radius = 17
        local offset     = FindWalkableOffset(inst:GetPosition(), 0, mid_radius, 10)
        if offset then
            local x, y, z = (inst:GetPosition() + offset):Get()
            child.Transform:SetPosition(x, y, z)
        end
    end)

    return inst
end

return Prefab("stariliad_boss_spyder", fn, assets),
    Prefab("stariliad_boss_spyder_spawner", spawner_fn, assets)
