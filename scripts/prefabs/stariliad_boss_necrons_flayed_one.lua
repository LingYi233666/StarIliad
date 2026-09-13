local cooking = require("cooking")

local assets =
{
    Asset("ANIM", "anim/klaus_basic.zip"),
    Asset("ANIM", "anim/klaus_actions.zip"),
    Asset("ANIM", "anim/klaus_build.zip"),
}

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function OnDestroyOther(inst, other)
    if other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.DIG and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end
end

local function OnCollide(inst, other)
    if other ~= nil and
        other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.DIG and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, OnDestroyOther, other)
    end
end

------------------------------------------------------------------------------------------------------

local function IsMeatIngredient(prefab)
    local COOKING_ALIASES = {
        cookedsmallmeat = "smallmeat_cooked",
        cookedmonstermeat = "monstermeat_cooked",
        cookedmeat = "meat_cooked",
    }

    local name = COOKING_ALIASES[prefab] or prefab
    local data = cooking.ingredients[name]

    return data and data.tags and data.tags.meat and data.tags.meat > 0
end

local function HasFreshLoots(ent)
    if not ent.components.lootdropper then
        return false
    end

    local possible_loots = ent.components.lootdropper:GetAllPossibleLoot()
    for k, v in pairs(possible_loots) do
        if v then
            if IsMeatIngredient(k) then
                return true
            end
        end
    end
end

local function RetargetFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15, { "_combat", "_health" }, { "INLIMBO", "stariliad_necrons" })
    for k, v in pairs(ents) do
        if inst.components.combat:CanTarget(v)
            and not inst.components.combat:IsAlly(v)
            and (HasFreshLoots(v)
            -- or v:HasOneOfTags({ "character", "largecreature" })
            ) then
            -- The flayed one desires living creature's fresh meat
            return v
        end
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target) and not inst.components.combat:IsAlly(target)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    MakeGiantCharacterPhysics(inst, 1000, 1.2)

    local SCALE = 1.4
    local xformscale = 1.2 * SCALE
    inst.Transform:SetScale(xformscale, xformscale, xformscale)
    inst.DynamicShadow:SetSize(3.5 * SCALE, 1.5 * SCALE)
    if SCALE > 1 then
        inst.Physics:SetMass(1000 * SCALE)
        inst.Physics:SetCapsule(1.2 * SCALE, 1)
    end

    inst.AnimState:SetBank("klaus")
    inst.AnimState:SetBuild("klaus_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:Hide("swap_chain")
    inst.AnimState:Hide("swap_chain_lock")

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("stariliad_necrons")

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.override_combat_fx_size   = "med"
    inst.override_combat_fx_height = "high"


    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    -- inst:AddComponent("sleeper")
    -- inst.components.sleeper:SetResistance(4)
    -- inst.components.sleeper:SetSleepTest(ShouldSleep)
    -- inst.components.sleeper:SetWakeTest(ShouldWake)
    -- inst.components.sleeper.diminishingreturns = true

    inst:AddComponent("locomotor")
    inst.components.locomotor.pathcaps = { ignorewalls = true }
    inst.components.locomotor.walkspeed = TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_SPEED

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_HEALTH)
    -- inst.components.health.nofadeout = true


    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_ATTACK_PERIOD)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_ATTACK_RANGE,
        TUNING.STARILIAD_BOSS_NECRONS_FLAYED_ONE_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.hiteffectsymbol = "swap_fire"

    inst:AddComponent("explosiveresist")

    inst:AddComponent("timer")

    inst:AddComponent("sanityaura")

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.KLAUS_EPICSCARE_RANGE)

    inst:AddComponent("knownlocations")

    inst:AddComponent("drownable")

    MakeLargeFreezableCharacter(inst, "swap_fire")
    inst.components.freezable:SetResistance(4)
    inst.components.freezable.diminishingreturns = true

    -- inst.DoFoleySounds = DoFoleySounds

    local brain = require("brains/stariliad_boss_necrons_flayed_one_brain")
    inst:SetBrain(brain)
    inst:SetStateGraph("SGstariliad_boss_necrons_flayed_one")

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end


return Prefab("stariliad_boss_necrons_flayed_one", fn, assets)
