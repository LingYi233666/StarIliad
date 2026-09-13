local assets =
{
    Asset("ANIM", "anim/toadstool_basic.zip"),
    Asset("ANIM", "anim/toadstool_actions.zip"),
    Asset("ANIM", "anim/toadstool_build.zip"),
    Asset("ANIM", "anim/toadstool_upg_build.zip"),

    Asset("ANIM", "anim/tentacle.zip"),

    Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_build.zip"),

    Asset("ANIM", "anim/stariliad_boss_toad_parasite_worms_fx.zip"),

    Asset("ANIM", "anim/whale_carcass.zip"),
    Asset("ANIM", "anim/whale_carcass_build.zip"),

    Asset("ANIM", "anim/winona_catapult_projectile.zip"),

    Asset("ANIM", "anim/stariliad_boss_toad_parasite_death_explode.zip"),
}

local BODY_TENTACLE_DATA = {
    -- {
    --     symbol = "toad_mushroom",
    --     pos = Vector3(0, 0, 0),
    --     anim_offset = Vector3(0, 0, 0),
    --     degree = 0,
    --     symbol_id_1 = 1,
    --     symbol_id_2 = 2,
    -- },

    {
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 60, 0),
        symbol_id_1 = 0,
    },

    {
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 60, 0),
        symbol_id_1 = 1,
    },

    {
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 60, 0),
        symbol_id_1 = 3,
    },

    {
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 0, 0),
        symbol_id_1 = 5,
    },

    {
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 80, 0),
        symbol_id_1 = 7,
    },

    {
        bank = "tentacle_arm",
        build = "tentacle_arm_build",
        symbol = "toad_mushroom",
        pos = Vector3(0, 0, 0),
        anim_offset = Vector3(0, 80, 0),
        symbol_id_1 = 10,
    },

    -- {
    --     bank = "tentacle_arm",
    --     build = "tentacle_arm_build",
    --     symbol = "toad_pupil",
    --     pos = Vector3(0, 0, 0),
    --     anim_offset = Vector3(0, 0, 0),
    --     symbol_id_1 = 0,
    -- },

}

-- local function AddBodyParasite(inst, symbol, pos, anim_offset, degree, symbol_id_1, symbol_id_2)
--     anim_offset = anim_offset or Vector3(0, 0, 0)
--     degree = degree or 0

--     local anchor = inst:SpawnChild("stariliad_boss_toad_parasite_body_tentacle_anchor")
--     anchor.entity:AddFollower()
--     anchor.Follower:FollowSymbol(inst.GUID, symbol, pos.x, pos.y, pos.z, true, nil, symbol_id_1, symbol_id_2)
--     anchor.AnimState:SetPercent("no_face", degree / 360)

--     local tentacle = anchor:SpawnChild("stariliad_boss_toad_parasite_body_tentacle")
--     tentacle.entity:AddFollower()
--     tentacle.Follower:FollowSymbol(anchor.GUID, "swap_object", anim_offset.x, anim_offset.y, anim_offset.z, true)

--     tentacle.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
--     tentacle.components.highlightchild:SetOwner(inst)
-- end

local function AddBodyParasite(inst, data)
    data.anim_offset = data.anim_offset or Vector3(0, 0, 0)
    data.degree = data.degree or 0

    local anchor = inst:SpawnChild("stariliad_boss_toad_parasite_body_tentacle_anchor")
    anchor.entity:AddFollower()
    anchor.Follower:FollowSymbol(inst.GUID, data.symbol, data.pos.x, data.pos.y, data.pos.z, true, nil, data.symbol_id_1,
        data.symbol_id_2)
    anchor.AnimState:SetPercent("no_face", data.degree / 360)

    local tentacle = anchor:SpawnChild("stariliad_boss_toad_parasite_body_tentacle")
    tentacle.entity:AddFollower()
    tentacle.Follower:FollowSymbol(anchor.GUID, "swap_object", data.anim_offset.x, data.anim_offset.y, data.anim_offset
        .z, true)

    if data.bank then
        tentacle.AnimState:SetBank(data.bank)
    end

    if data.build then
        tentacle.AnimState:SetBuild(data.build)
    end

    if data.anim then
        tentacle.AnimState:PlayAnimation(data.anim, true)
    end

    tentacle.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
    tentacle.components.highlightchild:SetOwner(inst)

    return anchor, tentacle
end

local function DropLootFn(lootdropper)
    local loot_and_weights = {
        red_mushroomhat_blueprint = 1,
        green_mushroomhat_blueprint = 1,
        blue_mushroomhat_blueprint = 1,
        sleepbomb_blueprint = 1,
        mushroom_light_blueprint = 0.05,
        mushroom_light2_blueprint = 0.01,
    }
    lootdropper:AddChanceLoot(weighted_random_choice(loot_and_weights), 1)
end

local function RetargetFn(inst)
    return FindEntity(inst, 25, function(target)
            return inst.components.combat:CanTarget(target) and not inst.components.combat:IsAlly(target)
        end,
        { "_combat", "_health" },
        { "INLIMBO", "prey", "smallcreature" }
    )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
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
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.DynamicShadow:SetSize(6, 3.5)

    MakeGiantCharacterPhysics(inst, 1000, 2.5)

    inst.AnimState:SetBank("toadstool")
    inst.AnimState:SetBuild("toadstool_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetSymbolMultColour("toad_mushroom", 0, 0, 0, 0)
    -- inst.AnimState:SetSymbolMultColour("toad_eye", 60 / 255, 34 / 255, 74 / 255, 1)
    -- inst.AnimState:SetSymbolMultColour("toad_pupil", 0, 0, 0, 0)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_toad_parasite")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    -- inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(DropLootFn)

    inst:AddComponent("locomotor")
    inst.components.locomotor.pathcaps = { ignorewalls = true }
    inst.components.locomotor.walkspeed = TUNING.STARILIAD_BOSS_TOAD_PARASITE_WALKSPEED

    inst:AddComponent("drownable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_BOSS_TOAD_PARASITE_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_POUND_DAMAGE)
    inst.components.combat:SetRange(TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.playerdamagepercent = TUNING.STARILIAD_BOSS_TOAD_PARASITE_PLAYERDAMAGEPERCENT
    -- inst.components.combat.battlecryenabled = false
    inst.components.combat.hiteffectsymbol = "toad_torso"

    inst:AddComponent("explosiveresist")

    inst:AddComponent("sanityaura")

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(20)

    inst:AddComponent("timer")

    inst:AddComponent("groundpounder")
    inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.radiusStepDistance = 2.5
    inst.components.groundpounder.ringWidth = 1.5
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 3
    inst.components.groundpounder.platformPushingRings = 0
    inst.components.groundpounder.numRings = 3
    inst.components.groundpounder.destroyer = true

    inst:AddComponent("knownlocations")

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "toad_torso")
    inst.components.freezable.diminishingreturns = true


    inst.anchor_and_tentacles = {}
    for _, data in pairs(BODY_TENTACLE_DATA) do
        local anchor, tentacle = AddBodyParasite(inst, data)
        table.insert(inst.anchor_and_tentacles, { anchor = anchor, tentacle = tentacle })
    end


    local brain = require("brains/stariliad_boss_toad_parasite_brain")
    inst:SetStateGraph("SGstariliad_boss_toad_parasite")
    inst:SetBrain(brain)


    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    return inst
end

local function body_tentacle_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("tentacle")
    inst.AnimState:SetBuild("tentacle")
    inst.AnimState:PlayAnimation("atk_idle", true)

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function body_tentacle_anchor_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stariliad_rotate_controller")
    inst.AnimState:SetBuild("stariliad_rotate_controller")

    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    return inst
end

local function WormEntitySleep(inst)
    inst.OnEntityWake = nil
    inst.OnEntitySleep = nil
end

local function WormEntityWake(inst)
    inst.SoundEmitter:PlaySound("hallowednights2025/spooks/worms")
    inst.OnEntityWake = nil
    inst.OnEntitySleep = nil
end

local function worms_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("worms_fx")
    inst.AnimState:SetBuild("stariliad_boss_toad_parasite_worms_fx")
    inst.AnimState:PlayAnimation("worms_spawn")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnEntityWake = WormEntityWake
    inst.OnEntitySleep = WormEntitySleep

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

local function explode_fn_1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("winona_catapult_projectile")
    inst.AnimState:SetBuild("stariliad_boss_toad_parasite_death_explode")
    inst.AnimState:PlayAnimation("impact3_special")

    inst.AnimState:HideSymbol("cloud_parts")

    local s = 2
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

local function explode_fn_2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("whalecarcass")
    inst.AnimState:SetBuild("whale_carcass_build")
    inst.AnimState:PlayAnimation("explode")

    inst.AnimState:HideSymbol("wateredge")
    inst.AnimState:HideSymbol("ripple_front")
    inst.AnimState:SetTime(57 * FRAMES)

    local s = 2
    inst.Transform:SetScale(s, s, s)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("stariliad_boss_toad_parasite", fn, assets),
    Prefab("stariliad_boss_toad_parasite_body_tentacle", body_tentacle_fn, assets),
    Prefab("stariliad_boss_toad_parasite_body_tentacle_anchor", body_tentacle_anchor_fn, assets),
    Prefab("stariliad_boss_toad_parasite_worms_fx", worms_fx_fn, assets),
    Prefab("stariliad_boss_toad_parasite_explode_fx_1", explode_fn_1, assets),
    Prefab("stariliad_boss_toad_parasite_explode_fx_2", explode_fn_2, assets)
