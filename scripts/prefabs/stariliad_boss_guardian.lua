local assets =
{
    Asset("ANIM", "anim/lavaarena_beetletaur.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_basic.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_actions.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_block.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
    Asset("ANIM", "anim/healing_flower.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

-- Note:
-- local sound_path = "dontstarve/forge2/beetletaur/"
-- sounds = {
--     taunt     = sound_path .. "taunt",
--     hit       = sound_path .. "hit",
--     hit_2     = sound_path .. "chain_hit",
--     stun      = sound_path .. "grunt",
--     attack    = sound_path .. "attack",
--     step      = sound_path .. "step",
--     swipe     = sound_path .. "swipe",
--     jump      = sound_path .. "jump",
-- }

local function RetargetFn(inst)
    if not inst.components.health:IsDead() then
        return FindEntity(inst, 10, function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            { "_combat", "_health" },
            { "INLIMBO", "smallcreature", "prey", "shadowcreature", "nightmarecreature", "shadow" },
            { "character", "largecreature" }
        )
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnHit(inst, attacker)
    inst.components.combat:SetTarget(attacker)
end

-------------------------------------------------------------------------------------------

local function SetDefensiveMode(inst, val, is_onload)
    local old = inst.defensive_mode
    inst.defensive_mode = val

    if old ~= inst.defensive_mode then
        inst:PushEvent("defensive_mode_change", { is_onload = is_onload })
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(4.5, 2.25)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.05, 1.05, 1.05)

    inst:SetPhysicsRadiusOverride(1.75)
    MakeCharacterPhysics(inst, 500, inst.physicsradiusoverride)

    inst.AnimState:SetBank("beetletaur")
    inst.AnimState:SetBuild("lavaarena_beetletaur")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:AddOverrideBuild("fossilized")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("epic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_GUARDIAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(0.33)
    inst.components.combat:SetRange(6)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetOnHit(OnHit)
    -- inst.components.combat:SetHurtSound("rifts4/goop/hit_big")
    inst.components.combat.playerdamagepercent = TUNING.STARILIAD_GUARDIAN_PLAYERDAMAGEPERCENT

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(4000)
    inst.components.health.destroytime = 8

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetChanceLootTable("stariliad_boss_guardian")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(40)

    inst:AddComponent("knownlocations")

    inst:AddComponent("explosiveresist")

    inst:SetStateGraph("SGstariliad_boss_guardian")

    ----------------------------------------------------------
    inst.defensive_mode = false

    inst.SetDefensiveMode = SetDefensiveMode

    ----------------------------------------------------------

    return inst
end


local function break_fx_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("beetletaur_break")
    inst.AnimState:SetBuild("lavaarena_beetletaur_break")
    inst.AnimState:PlayAnimation("anim")
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")
    end)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


return Prefab("stariliad_boss_guardian", fn, assets),
    Prefab("stariliad_boss_guardian_break_fx", break_fx_fn, assets)
