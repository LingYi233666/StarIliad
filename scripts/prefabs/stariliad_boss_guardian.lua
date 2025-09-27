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

    Asset("ANIM", "anim/stariliad_boss_guardian.zip"),
    Asset("ANIM", "anim/stariliad_boss_guardian_no_power.zip"),
    -- Asset("ANIM", "anim/stariliad_boss_guardian_head_fix.zip"),
}

SetSharedLootTable("stariliad_boss_guardian",
    {
        { "blythe_unlock_skill_item_super_missile", 1.0 },
        { "gears",                                  1.0 },
        { "gears",                                  0.5 },
        { "nightmarefuel",                          1.0 },
        { "transistor",                             1.0 },
        { "transistor",                             1.0 },
    }
)


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

local function OnCollapse(inst, other)
    if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
end

local function OnCollide(inst, other)
    if other ~= nil and (other:HasTag("tree") or other:HasTag("boulder")) and Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 then
        inst:DoTaskInTime(2 * FRAMES, OnCollapse, other)
    end
end

-------------------------------------------------------------------------------------------

local function CheckLightOverride(inst)
    if inst.Light:IsEnabled() then
        local percent = inst._light_factor:value()
        local light_override = Remap(percent, 0, 1, 0, 1)
        inst.AnimState:SetLightOverride(light_override)
    else
        inst.AnimState:SetLightOverride(0)
    end
end

local function OnLightFactorDirty(inst)
    local percent = inst._light_factor:value()
    local radius = Remap(percent, 0, 1, 4, 7)
    local intensity = Remap(percent, 0, 1, 0.4, 0.5)

    inst.Light:SetRadius(radius)
    inst.Light:SetIntensity(intensity)

    CheckLightOverride(inst)
end


local function SetDefensiveMode(inst, val, is_onload)
    local old = inst.defensive_mode
    inst.defensive_mode = val

    if old ~= inst.defensive_mode then
        if inst.stop_defense_task then
            inst.stop_defense_task:Cancel()
            inst.stop_defense_task = nil
        end

        if val then
            inst.stop_defense_task = inst:DoTaskInTime(TUNING.STARILIAD_BOSS_GUARDIAN_DEFENSIVE_DURATION, function()
                inst:SetDefensiveMode(false)
                inst.ability_name = "combo_punch"
                inst.can_use_ability_time = GetTime() + 3

                -- inst.components.combat:ResetCooldown()

                inst.stop_defense_task = nil
            end)
        end

        -- if val then
        --     inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_GUARDIAN_ATTACK_PERIOD_DEFENSIVE)
        -- else
        --     inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_GUARDIAN_ATTACK_PERIOD)
        -- end


        inst:PushEvent("defensive_mode_change", { is_onload = is_onload })
    end
end

local function SetBluePower(inst, enable)
    if enable then
        -- inst.AnimState:ShowSymbol("horns")
        inst.AnimState:ShowSymbol("arm_upper")

        inst.AnimState:ClearOverrideSymbol("hand")
        inst.AnimState:ClearOverrideSymbol("body")
        inst.AnimState:ClearOverrideSymbol("arm_lower")
    else
        -- inst.AnimState:HideSymbol("horns")
        inst.AnimState:HideSymbol("arm_upper")

        inst.AnimState:OverrideSymbol("hand", "stariliad_boss_guardian_no_power", "hand")
        inst.AnimState:OverrideSymbol("body", "stariliad_boss_guardian_no_power", "body")
        inst.AnimState:OverrideSymbol("arm_lower", "stariliad_boss_guardian_no_power", "arm_lower")
    end

    inst.Light:Enable(enable)

    CheckLightOverride(inst)
end

local function TurnOffLight(inst)
    if inst.turn_light_task then
        inst.turn_light_task:Cancel()
        inst.turn_light_task = nil
    end

    local duration = 1
    local speed = inst._light_factor:value() / duration

    inst.turn_light_task = inst:DoPeriodicTask(0, function()
        local factor = inst._light_factor:value() - speed * FRAMES
        factor = math.max(factor, 0)

        inst._light_factor:set(factor)

        if factor <= 0 then
            inst.turn_light_task:Cancel()
            inst.turn_light_task = nil
        end
    end)
end

local EYE_FLAMES_DATA = {
    { pos = Vector3(0, -90, 0),   symbol = 0 },
    { pos = Vector3(137, -70, 0), symbol = 1 },
    { pos = Vector3(0, -14, 0),   symbol = 3 },

    { pos = Vector3(7, -18, 0),   symbol = 4 },

    { pos = Vector3(-40, 92, 0),  symbol = 5 },

    { pos = Vector3(6, -20, 0),   symbol = 6 },

    -- { pos = Vector3(5, -27, 0),   symbol = 7 },
    -- { pos = Vector3(5, -14, 0),   symbol = 8 },

    { pos = Vector3(5, -27, 0),   symbol = { 7, 9 } },
    { pos = Vector3(1, -111, 0),  symbol = 9 },
    { pos = Vector3(7, -91, 0),   symbol = 10 },


}

local function SetEyeFlame(inst, dtype)
    -- if inst.eye_flame and inst.eye_flame:IsValid() then
    --     inst.eye_flame:Remove()
    -- end
    -- inst.eye_flame = nil

    for _, v in pairs(inst.eye_flames) do
        v:Remove()
    end
    inst.eye_flames = {}


    local prefab = nil

    if dtype == 0 then

    elseif dtype == 1 then
        prefab = "stariliad_boss_guardian_eye_flame_blue"
    elseif dtype == 2 then
        prefab = "stariliad_boss_guardian_eye_flame_red"
    end

    if prefab then
        -- inst.eye_flames

        for _, data in pairs(EYE_FLAMES_DATA) do
            local flame = inst:SpawnChild(prefab)
            flame.entity:AddFollower()

            if type(data.symbol) == "number" then
                flame.Follower:FollowSymbol(inst.GUID, "head", data.pos.x, data.pos.y, data.pos.z, true, nil, data
                    .symbol)
            elseif type(data.symbol) == "table" then
                flame.Follower:FollowSymbol(inst.GUID, "head", data.pos.x, data.pos.y, data.pos.z, true, nil,
                    data.symbol[1], data.symbol[2])
            end
            table.insert(inst.eye_flames, flame)
        end
    end
end


local function OnSave(inst, data)
    data.damage_threshold = inst.damage_threshold
    data.damage_to_defense = inst.damage_to_defense
    data.defensive_mode = inst.defensive_mode
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.damage_threshold ~= nil then
            inst.damage_threshold = data.damage_threshold
        end

        if data.damage_to_defense ~= nil then
            inst.damage_to_defense = data.damage_to_defense
        end

        if data.defensive_mode ~= nil then
            inst:SetDefensiveMode(data.defensive_mode, true)
        end
    end
end


local function OnHealthDelta(inst, data)
    if not inst.components.health:IsDead() and data.amount < 0 and not inst.defensive_mode then
        inst.damage_to_defense = inst.damage_to_defense + data.amount
        if inst.damage_to_defense <= 0 then
            inst:SetDefensiveMode(true)

            inst.damage_threshold = math.min(inst.damage_threshold + 34, 500)
            inst.damage_to_defense = inst.damage_threshold
        end
    end
end

local function OnAttacked(inst, data)
    if inst.defensive_mode then
        inst.components.combat:ResetCooldown()
    end
end

local function OnNewCombatTarget(inst, data)
    if inst.loss_target_task then
        inst.loss_target_task:Cancel()
        inst.loss_target_task = nil
    end

    if inst.old_target_fix == nil and (inst.last_loss_target_time == nil or GetTime() - inst.last_loss_target_time >= 5) then
        print("Reset to destroy3")
        inst.ability_name = "destroy3"
        inst.can_use_ability_time = GetTime() + 6
    end

    inst.old_target_fix = data.target

    inst:SetMusicLevel(2)
end

local function OnDroppedTarget(inst, data)
    if inst.loss_target_task then
        inst.loss_target_task:Cancel()
    end

    inst.loss_target_task = inst:DoTaskInTime(5, function()
        inst:SetDefensiveMode(false)
        inst:SetMusicLevel(1)
        inst.loss_target_task = nil
    end)

    inst.old_target_fix = nil
    inst.last_loss_target_time = GetTime()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.entity:AddLight()

    -- inst.Light:SetFalloff(0.6)
    -- inst.Light:SetIntensity(.5)
    -- inst.Light:SetRadius(0.5)

    -- inst.Light:SetFalloff(3)
    -- inst.Light:SetIntensity(.6)
    -- inst.Light:SetRadius(8)

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(7)

    inst.Light:SetColour(237 / 255, 237 / 255, 209 / 255)
    inst.Light:Enable(true)

    inst.AnimState:SetLightOverride(1)

    inst.DynamicShadow:SetSize(4.5, 2.25)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.05, 1.05, 1.05)

    inst:SetPhysicsRadiusOverride(1.75)
    MakeCharacterPhysics(inst, 500, inst.physicsradiusoverride)

    inst.AnimState:SetBank("beetletaur")
    inst.AnimState:SetBuild("stariliad_boss_guardian")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:AddOverrideBuild("fossilized")
    -- inst.AnimState:OverrideSymbol("head", "stariliad_boss_guardian_head_fix", "head")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("epic")
    inst:AddTag("noepicmusic")


    inst:AddComponent("talker")
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
    inst.components.talker.offset = Vector3(0, -250, 0)
    inst.components.talker.symbol = "head"
    -- inst.components.talker.name_colour = Vector3(233 / 256, 85 / 256, 107 / 256)
    -- inst.components.talker.chaticon = "npcchatflair_stalker"
    -- inst.components.talker:MakeChatter()

    -- inst._light_enable = net_bool(inst.GUID, "inst._light_enable", "m_lightdirty")
    -- inst._light_enable:set(true)


    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_guardian")


    inst._light_factor = net_float(inst.GUID, "inst._light_factor", "lightfactordirty")
    inst._light_factor:set(1.0)
    inst:ListenForEvent("lightfactordirty", OnLightFactorDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GUARDIAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_GUARDIAN_ATTACK_PERIOD)
    inst.components.combat:SetRange(6)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetOnHit(OnHit)
    -- inst.components.combat:SetHurtSound("rifts4/goop/hit_big")
    inst.components.combat.playerdamagepercent = TUNING.STARILIAD_BOSS_GUARDIAN_PLAYERDAMAGEPERCENT

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(4000)
    inst.components.health.destroytime = 8

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_boss_guardian")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(40)

    inst:AddComponent("knownlocations")

    inst:AddComponent("explosiveresist")

    local brain = require("brains/stariliad_boss_guardian_brain")
    inst:SetStateGraph("SGstariliad_boss_guardian")
    inst:SetBrain(brain)

    ----------------------------------------------------------
    inst.defensive_mode = false
    inst.damage_threshold = 200
    inst.damage_to_defense = inst.damage_threshold
    inst.eye_flames = {}

    inst.SetDefensiveMode = SetDefensiveMode
    inst.SetBluePower = SetBluePower
    inst.TurnOffLight = TurnOffLight
    inst.SetEyeFlame = SetEyeFlame
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ----------------------------------------------------------


    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    -- inst:SetEyeFlame(1)

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
