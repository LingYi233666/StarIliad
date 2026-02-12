local assets =
{
    Asset("ANIM", "anim/stariliad_boss_hexa_ghost.zip"),
}

local ROTATION_SPEED_1 = 30
local ROTATION_SPEED_2 = 120

--------------------------------------- NOTES ---------------------------------------
-- Surrounding fire ignite fx, see FireBurstParticleEffect.java

-- HexaghostOrb.java
-- GhostlyFireEffect.java
-- GhostlyWeakFireEffect.java

-- Surrounding fire pos:
-- this.orbs.add(new HexaghostOrb(-90.0F, 380.0F, this.orbs.size()));
-- this.orbs.add(new HexaghostOrb(90.0F, 380.0F, this.orbs.size()));
-- this.orbs.add(new HexaghostOrb(160.0F, 250.0F, this.orbs.size()));
-- this.orbs.add(new HexaghostOrb(90.0F, 120.0F, this.orbs.size()));
-- this.orbs.add(new HexaghostOrb(-90.0F, 120.0F, this.orbs.size()));
-- this.orbs.add(new HexaghostOrb(-160.0F, 250.0F, this.orbs.size()));

-- projectile:


-- Screen hell fires, see GiantFireEffect.java

-------------------------------------------------------------------------------------

SetSharedLootTable("stariliad_boss_hexa_ghost",
    {
        { "blythe_unlock_skill_item_super_missile", 1.0 },
    }
)

local function SetAllPlasmaRotationSpeed(inst, speed)
    inst.plasmas[1]:SetRotationSpeed(speed)
    inst.plasmas[2]:SetRotationSpeed(speed / 2)
    inst.plasmas[3]:SetRotationSpeed(speed / 3)
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

    -- inst.Light:SetFalloff(1)
    -- inst.Light:SetIntensity(.5)
    -- inst.Light:SetRadius(7)

    -- inst.Light:SetColour(237 / 255, 237 / 255, 209 / 255)
    -- inst.Light:Enable(true)

    inst.AnimState:SetLightOverride(1)

    inst.DynamicShadow:SetSize(4.5, 2.25)
    inst.Transform:SetTwoFaced()

    MakeGhostPhysics(inst, 500, 1)

    inst.AnimState:SetBank("stariliad_boss_hexa_ghost")
    inst.AnimState:SetBuild("stariliad_boss_hexa_ghost")
    inst.AnimState:PlayAnimation("idle", true)


    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("epic")
    inst:AddTag("noepicmusic")

    for i = 1, 3 do
        inst.AnimState:SetSymbolMultColour("plasma_" .. i, 1, 1, 1, 0)
    end

    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_hexa_ghost")

    -- inst._light_factor = net_float(inst.GUID, "inst._light_factor", "lightfactordirty")
    -- inst._light_factor:set(1.0)
    -- inst:ListenForEvent("lightfactordirty", OnLightFactorDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    inst:AddComponent("combat")
    -- inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOXX_HEXA_GHOST_DAMAGE)
    -- inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOXX_HEXA_GHOST_ATTACK_PERIOD)
    -- inst.components.combat:SetRange(6)
    -- inst.components.combat:SetRetargetFunction(1, RetargetFn)
    -- inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    -- inst.components.combat:SetOnHit(OnHit)
    -- inst.components.combat:SetHurtSound("rifts4/goop/hit_big")
    -- inst.components.combat.playerdamagepercent = TUNING.STARILIAD_BOXX_HEXA_GHOST_PLAYERDAMAGEPERCENT

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1000)
    -- inst.components.health.destroytime = 8
    inst.components.health.destroytime = 12

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_boss_hexa_ghost")


    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(40)

    inst:AddComponent("explosiveresist")


    inst.plasmas = {}

    -- Init plasma
    for i = 1, 3 do
        local plasma = inst:SpawnChild("stariliad_boss_hexa_ghost_plasma_" .. i)
        plasma.entity:AddFollower()
        plasma.Follower:FollowSymbol(inst.GUID, "plasma_" .. i, nil, nil, nil, true)

        plasma.components.highlightchild:SetOwner(inst)

        inst.components.colouradder:AttachChild(plasma)

        table.insert(inst.plasmas, plasma)
    end

    SetAllPlasmaRotationSpeed(inst, ROTATION_SPEED_1)



    inst.SetAllPlasmaRotationSpeed = SetAllPlasmaRotationSpeed


    -- inst:ListenForEvent("attacked", OnAttacked)
    -- inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    -- inst:ListenForEvent("droppedtarget", OnDroppedTarget)
    -- inst:ListenForEvent("loot_prefab_spawned", OnLootSpawned)



    return inst
end

local function MakePlasmaFn(index)
    -- speed unit: deg/s
    local function SetRotationSpeed(inst, speed)
        local default_speed = 10 -- deg/s

        inst.AnimState:SetDeltaTimeMultiplier(speed / default_speed)
    end

    local function fxfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("stariliad_boss_hexa_ghost")
        inst.AnimState:SetBuild("stariliad_boss_hexa_ghost")
        inst.AnimState:PlayAnimation("plasma", true)
        inst.AnimState:SetLightOverride(1)

        inst.AnimState:OverrideSymbol("plasma_1", "stariliad_boss_hexa_ghost", "plasma_" .. tostring(index))

        inst:AddTag("FX")

        inst:AddComponent("highlightchild")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("colouradder")

        inst.persists = false

        inst.SetRotationSpeed = SetRotationSpeed

        return inst
    end

    return Prefab("stariliad_boss_hexa_ghost_plasma_" .. tostring(index), fxfn, assets)
end


return Prefab("stariliad_boss_hexa_ghost", fn, assets),
    MakePlasmaFn(1),
    MakePlasmaFn(2),
    MakePlasmaFn(3)
