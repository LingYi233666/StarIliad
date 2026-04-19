local assets =
{
    Asset("ANIM", "anim/stariliad_lava_meteor.zip"),
    Asset("ANIM", "anim/stariliad_ice_meteor.zip"),

    Asset("ANIM", "anim/sharkboi_iceplow_fx.zip"),
}

SetSharedLootTable("stariliad_ice_meteor",
    {
        { "ice",   0.90 },
        { "ice",   0.50 },
        { "ice",   0.25 },

        { "flint", 0.50 },

        { "rocks", 0.90 },
        { "rocks", 0.25 },
    }
)


local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED = 8
local function launch_away(inst, position)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

    local px, py, pz = position:Get()
    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(SPEED * cosa, 4 + SPEED, SPEED * sina)
end


local function OnGroundPound(inst)
    local position = inst:GetPosition()
    local x, y, z = position:Get()

    local ents = TheSim:FindEntities(x, y, z, 6, nil, { "INLIMBO", "FX", "groundpound_immune" })

    for _, v in pairs(ents) do
        if v:IsValid() then
            if v:HasTag("boat") and v.components.health and not v.components.health:IsDead() then
                -- Destroy boats
                v.components.health:Kill()
            elseif v.components.oceanfishable ~= nil then
                -- Splash the fishes
                local projectile = v.components.oceanfishable:MakeProjectile()

                local ae_cp = projectile.components.complexprojectile
                if ae_cp then
                    ae_cp:SetHorizontalSpeed(16)
                    ae_cp:SetGravity(-30)
                    ae_cp:SetLaunchOffset(Vector3(0, 0.5, 0))
                    ae_cp:SetTargetOffset(Vector3(0, 0.5, 0))

                    local v_position = v:GetPosition()
                    local launch_position = v_position + (v_position - position):Normalize() * SPEED
                    ae_cp:Launch(launch_position, projectile, ae_cp.owningweapon)
                else
                    launch_away(projectile, position)
                end
            elseif v.prefab == "bullkelp_plant" then
                -- Splash the kelps
                local ae_x, ae_y, ae_z = v.Transform:GetWorldPosition()

                if v.components.pickable and v.components.pickable:CanBePicked() then
                    local product = v.components.pickable.product
                    local loot = SpawnPrefab(product)
                    if loot ~= nil then
                        loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                        if loot.components.inventoryitem ~= nil then
                            loot.components.inventoryitem:InheritWorldWetnessAtTarget(v)
                        end
                        if loot.components.stackable ~= nil
                            and v.components.pickable.numtoharvest > 1 then
                            loot.components.stackable:SetStackSize(v.components.pickable.numtoharvest)
                        end
                        launch_away(loot, position)
                    end
                end

                local uprooted_kelp_plant = SpawnPrefab("bullkelp_root")
                if uprooted_kelp_plant ~= nil then
                    uprooted_kelp_plant.Transform:SetPosition(ae_x, ae_y, ae_z)
                    launch_away(uprooted_kelp_plant, position + Vector3(0.5 * math.random(), 0, 0.5 * math.random()))
                end

                v:Remove()
            elseif v.prefab == "stariliad_ice_meteor_remain" then
                v:RemainExplode()
            end
        end
    end
end

local function HitGround(inst)
    local on_platform = inst:GetCurrentPlatform() ~= nil

    if inst:IsOnPassablePoint() then
        -- Normal ground or boat
        SpawnAt("sharkboi_iceimpact_fx", inst)
        SpawnAt("stariliad_ice_meteor_impact_fx", inst)

        if not on_platform then
            SpawnAt("stariliad_ice_meteor_impact_ground_fx", inst)
        end

        inst.components.lootdropper:DropLoot()
    elseif inst:IsOnOcean() then
        -- Ocean

        for i = 1, 7 do
            local offset = Vector3FromTheta(math.random() * TWOPI, GetRandomMinMax(0, 3))

            SpawnAt("crab_king_waterspout", inst, { 1.2, 1.2, 1.2 }, offset)
        end

        -- Spawn waves
        SpawnAttackWaves(inst:GetPosition(), nil, 2, 8, 360, 6)
    else
        -- Void
        -- TODO: Maybe do sth....
    end

    inst.components.groundpounder:GroundPound()

    inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/meteor_strike")
    inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")
    -- inst.SoundEmitter:PlaySound("dontstarve/common/meteor_impact")

    for i, v in ipairs(AllPlayers) do
        local power = Lerp(3, 1, math.sqrt(inst:GetDistanceSqToInst(v)) / 180)
        v:ShakeCamera(CAMERASHAKE.VERTICAL, 0.5, 0.03, power, inst, 40)
    end
end

local function StartMeteor(inst, force_remain)
    local whole_time = TUNING.STARILIAD_ICE_METEOR_LANDING_DURATION
    local collide_time = 8 * FRAMES

    SpawnAt("stariliad_meteor_shadow", inst):StartFX(whole_time)

    -- Play warning sound
    inst.SoundEmitter:PlaySound("dontstarve/common/meteor_spawn")
    -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/ice_meteor/fall")


    inst:DoTaskInTime(whole_time - collide_time, function()
        inst.Transform:SetRotation(math.random(-180, 180))

        if (force_remain or math.random() < 0.1) and inst:GetCurrentPlatform() == nil then
            inst.AnimState:PlayAnimation("egg_crash_pre")
        else
            inst.AnimState:PlayAnimation("idle")
        end
    end)

    inst:DoTaskInTime(whole_time, HitGround)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("stariliad_lava_meteor")
    inst.AnimState:SetBuild("stariliad_ice_meteor")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.StartMeteor = StartMeteor

    -- inst:AddComponent("groundpounder")
    -- inst.components.groundpounder.numRings = 4
    -- inst.components.groundpounder.ringDelay = 0.1
    -- inst.components.groundpounder.initialRadius = 1
    -- inst.components.groundpounder.radiusStepDistance = 2
    -- inst.components.groundpounder.pointDensity = .25
    -- inst.components.groundpounder.damageRings = 2
    -- inst.components.groundpounder.destructionRings = 3
    -- inst.components.groundpounder.destroyer = true
    -- inst.components.groundpounder.burner = true
    -- inst.components.groundpounder.ring_fx_scale = 0.75

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_ice_meteor")
    inst.components.lootdropper.min_speed = 0.5
    inst.components.lootdropper.max_speed = 6
    inst.components.lootdropper.y_speed = 8
    inst.components.lootdropper.y_speed_variance = 4

    inst:AddComponent("groundpounder")
    inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.burner = false
    -- inst.components.groundpounder.groundpoundfx = "stariliad_ice_meteor_plow_fx"
    inst.components.groundpounder.numRings = 4
    inst.components.groundpounder.ringDelay = 0.1
    inst.components.groundpounder.initialRadius = 1
    inst.components.groundpounder.radiusStepDistance = 2
    inst.components.groundpounder.pointDensity = .25
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 3
    inst.components.groundpounder.inventoryPushingRings = 4
    inst.components.groundpounder.groundpoundFn = OnGroundPound

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_ICE_METEOR_DAMAGE)

    inst:ListenForEvent("animover", function()
        inst:Hide()

        if inst.AnimState:IsCurrentAnimation("egg_crash_pre") then
            local remain = SpawnAt("stariliad_ice_meteor_remain", inst)
            remain.Transform:SetRotation(inst.Transform:GetRotation())
            remain.AnimState:PlayAnimation("egg_crash")
            remain.AnimState:PushAnimation("egg_idle", false)
        end

        -- Keep to play the sound
        inst:DoTaskInTime(1, inst.Remove)
    end)

    return inst
end

-----------------------------------------------------------

local function OnRemainIgnite(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    DefaultBurnFn(inst)

    inst.components.timer:StopTimer("self_ignite")
end

local function RemainExplode(inst)
    if not inst.exploded then
        SpawnAt("sharkboi_iceimpact_fx", inst)
        SpawnAt("stariliad_ice_meteor_impact_fx", inst)
        -- SpawnAt("stariliad_ice_meteor_remain_ground", inst)
        -- if inst:GetCurrentPlatform() == nil then
        --     SpawnAt("stariliad_ice_meteor_impact_ground_fx", inst)
        -- end

        inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/meteor_strike")
        inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")

        ShakeAllCameras(CAMERASHAKE.FULL, .7, .03, 0.5, inst, 40)

        inst.components.timer:StopTimer("self_ignite")

        inst.persists = false
        inst.exploded = true
        inst:Hide()
        inst:DoTaskInTime(1, inst.Remove)
    end
end

local function OnRemainBurnt(inst)
    RemainExplode(inst)
end

local function OnRemainExtinguish(inst)
    inst.SoundEmitter:KillSound("hiss")
    DefaultExtinguishFn(inst)
end

local function OnRemainTimerDone(inst, data)
    if data.name == "self_ignite" then
        inst.components.burnable.fxdata = {}
        inst.components.burnable:SetFXLevel(4)
        -- inst.components.burnable:AddBurnFX("coldfirefire", Vector3(-30, -50, 0), "rock01")
        inst.components.burnable:AddBurnFX("coldfirefire", Vector3(0, 150, 0), "rock01")
        inst.components.burnable:Ignite(true)

        local fire = inst.components.burnable.fxchildren[1]
        if fire and fire:IsValid() then
            fire.Transform:SetScale(2, 1.5, 1)
        end
    end
end

local function remain_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    -- inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("stariliad_lava_meteor")
    inst.AnimState:SetBuild("stariliad_ice_meteor")
    inst.AnimState:PlayAnimation("egg_idle")

    MakeObstaclePhysics(inst, 1)

    -- inst.MiniMapEntity:SetIcon("iceboulder.png")

    -- inst:AddTag("antlion_sinkhole_blocker")
    -- inst:AddTag("frozen")
    -- MakeSnowCoveredPristine(inst)

    inst:SetPrefabNameOverride("stariliad_ice_meteor")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.RemainExplode = RemainExplode

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("savedrotation")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("self_ignite", GetRandomMinMax(1, 3) * TUNING.TOTAL_DAY_TIME)
    -- inst.components.timer:StartTimer("self_ignite", 5)

    -- MakeSmallBurnable(inst, 3 + math.random() * 3)
    -- MakeMediumBurnable(inst, 3 + math.random() * 3)
    MakeLargeBurnable(inst, 3 + math.random() * 3, Vector3(0, 90, 0), nil, "rock01")
    inst.components.burnable:SetOnIgniteFn(OnRemainIgnite)
    inst.components.burnable:SetOnBurntFn(OnRemainBurnt)
    inst.components.burnable:SetOnExtinguishFn(OnRemainExtinguish)

    -- MakeHauntableWork(inst)

    inst:ListenForEvent("timerdone", OnRemainTimerDone)

    return inst
end

-----------------------------------------------------------


local function remain_ground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("stariliad_lava_meteor")
    inst.AnimState:SetBuild("stariliad_ice_meteor")
    inst.AnimState:PlayAnimation("egg_idle")
    inst.AnimState:HideSymbol("rock01")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("remove", math.random(60, 120))

    inst:ListenForEvent("timerdone", function(_, data)
        if data.name == "remove" then
            inst.persists = false
            ErodeAway(inst)
        end
    end)

    return inst
end

local function iceplow_KillFX(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("iceplow" .. tostring(inst.variation) .. "_pst")
end


local function iceplow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("sharkboi_iceplow_fx")
    inst.AnimState:SetBuild("sharkboi_iceplow_fx")
    inst.AnimState:PlayAnimation("iceplow1_pre")
    inst.AnimState:SetFinalOffset(1)

    -- inst.AnimState:HideSymbol("shad")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.variation = math.random(2)

    if inst.variation ~= 1 then
        inst.AnimState:PlayAnimation("iceplow" .. tostring(inst.variation) .. "_pre")
    end
    inst.AnimState:SetTime(24 * FRAMES)

    inst.AnimState:PushAnimation("iceplow" .. tostring(inst.variation) .. "_idle", false)
    local scale = 0.6 + math.random() * 0.4
    inst.AnimState:SetScale(math.random() < 0.5 and -scale or scale, scale)

    inst.persists = false
    inst:DoTaskInTime(1.35 + math.random() * 0.3, iceplow_KillFX)

    return inst
end

-----------------------------------------------------------

local function impact_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deerclops")
    inst.AnimState:SetBuild("deerclops_mutated")
    inst.AnimState:PlayAnimation("ice_impact")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-----------------------------------------------------------

local function impact_ground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_ice_circle")
    inst.AnimState:SetBuild("deer_ice_circle")
    inst.AnimState:PlayAnimation("impact")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.76, 1.76)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(math.random(8, 16), function()
        inst:ListenForEvent("animover", inst.Remove)
        inst.AnimState:PlayAnimation("pst")
    end)

    return inst
end


return Prefab("stariliad_ice_meteor", fn, assets),
    Prefab("stariliad_ice_meteor_remain", remain_fn, assets),
    Prefab("stariliad_ice_meteor_remain_ground", remain_ground_fn, assets),
    Prefab("stariliad_ice_meteor_plow_fx", iceplow_fn, assets),
    Prefab("stariliad_ice_meteor_impact_fx", impact_fn, assets),
    Prefab("stariliad_ice_meteor_impact_ground_fx", impact_ground_fn, assets)
