local assets =
{
    Asset("ANIM", "anim/crickant_queen_basics.zip"),
    Asset("ANIM", "anim/stariliad_boss_gorgoroth.zip"),
    Asset("ANIM", "anim/stariliad_boss_gorgoroth_head.zip"),

    Asset("ANIM", "anim/meteor.zip"),

    Asset("ANIM", "anim/stariliad_gelblob_meteor.zip"),

}

local brain = require "brains/stariliad_boss_gorgoroth_brain"


SetSharedLootTable("stariliad_boss_gorgoroth",
    {
        { "blythe_unlock_skill_item_super_missile", 1.0 },
        { "stariliad_hat_gelblob",                  1.0 },
        { "nightmarefuel",                          1.0 },
        { "nightmarefuel",                          1.0 },
        { "nightmarefuel",                          1.0 },
        { "nightmarefuel",                          1.0 },
        { "nightmarefuel",                          1.0 },
        { "nightmarefuel",                          1.0 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
        { "fossil_piece",                           1.00 },
    }
)


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

------------------------------------------------------------------
--- Special functions

local function SpawnTrails(inst, pos, radius, num_trails, duration, duration_var)
    pos = pos or inst:GetPosition()
    radius = radius or 1
    num_trails = num_trails or (2 + math.random() * 3)
    duration = duration or 2.5
    duration_var = duration_var or 1

    for i = 1, num_trails do
        local offset = Vector3(UnitRand() * radius, 0, UnitRand() * radius)
        local trail = SpawnAt("stariliad_boss_gorgoroth_trail", pos, nil, offset)

        -- local trail = SpawnAt("honey_trail", pos, nil, offset)
        -- trail.AnimState:SetBank("damp_trail")
        -- trail.AnimState:SetBuild("damp_trail")
        -- trail.AnimState:SetMultColour(0, 0, 0, 0.5)
        trail:SetVariation(math.random(1, 7), 1 + math.random() * 0.55, duration + UnitRand() * duration_var)
    end
end

local function DoPoundDamage(inst, radius, instancemult)
    radius = radius or 1

    local search_radius = radius + inst:GetPhysicsRadius(0) + 4 -- Gorgoroth is large, so check physics radius also
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, search_radius, nil, { "INLIMBO", "FX" })

    for _, v in pairs(ents) do
        if inst:IsNear(v, radius + inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0)) then
            if v.components.workable and v.components.workable:CanBeWorked() and v.components.workable.action ~= ACTIONS.NET then
                v.components.workable:WorkedBy(inst, 20)
            elseif v.components.combat and inst.components.combat:CanTarget(v) then
                inst.components.combat:DoAttack(v, nil, nil, nil, instancemult, 99999)
            end
        end
    end
end

local function ShakeItems(inst, radius)
    local search_radius = inst:GetPhysicsRadius(0) + radius

    local x, y, z = inst.Transform:GetWorldPosition()

    local totoss = TheSim:FindEntities(x, 0, z, search_radius, { "_inventoryitem" }, { "locomotor", "INLIMBO" })
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
            -- StarIliadBasic.LaunchItem(v, inst, 2, PHYSICS_RADIUS * .4, PHYSICS_RADIUS + v:GetPhysicsRadius(0))

            -- local xz_speed = math.random() * 4 + 2
            -- local y_speed = math.random() * 2 + 8
            -- local angle = 180 + v:GetAngleToPoint(x, y, z)
            -- StarIliadBasic.LaunchItem(v, xz_speed, y_speed, angle)

            local direction = (v:GetPosition() - Vector3(x, y, z))
            local dist = direction:Length()
            direction = direction / dist

            -- local h_speed = math.random() * 2 + Remap(dist, 0, search_radius, 8, 2)

            -- local v_speed = math.random() * 2 + 12
            local v_speed = Remap(dist, 0, search_radius, 12, 8) + math.random() * 2
            local h_speed = 0
            local has_h_speed_dist = inst:GetPhysicsRadius(0) + 2
            if dist <= has_h_speed_dist then
                h_speed = math.random() + Remap(dist, 0, has_h_speed_dist, 8, 0)
            end

            local vel = direction * h_speed + Vector3(0, v_speed, 0)
            v.Physics:SetVel(vel:Get())
        end
    end
end

local function CheckHopCooldown(inst, cooldown)
    return inst.last_hop_time == nil or GetTime() - inst.last_hop_time > (cooldown or 2)
end

local function GenerateSpitPos(inst, required_num)
    local pos_queue = {}
    local min_dist = 6

    for _, v in pairs(AllPlayers) do
        if inst:IsNear(v, 40) and not inst:IsNear(v, min_dist) and not IsEntityDeadOrGhost(v, true) then
            -- table.insert(pos_queue, v:GetPosition())
            table.insert(pos_queue, v)
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, { "_combat" }, { "INLIMBO", "FX" })

    for _, v in pairs(ents) do
        if not v:HasTag("player") and not inst:IsNear(v, min_dist) and v.components.combat:TargetIs(inst) then
            -- table.insert(pos_queue, v:GetPosition())
            table.insert(pos_queue, v)
        end
    end


    local remain_count = required_num - #pos_queue
    if remain_count > 0 then
        for i = 1, remain_count do
            local offset = FindWalkableOffset(Vector3(x, y, z), math.random() * PI2, GetRandomMinMax(10, 30), 10, nil,
                nil, nil, false, true)
            if offset then
                table.insert(pos_queue, Vector3(x, y, z) + offset)
            end
        end
    end

    pos_queue = shuffleArray(pos_queue)

    local result = {}
    for i = 1, math.min(#pos_queue, required_num) do
        table.insert(result, pos_queue[i])
    end

    return result
end

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("rifts4/goop/minion_blob_wobble_lp", "loop")
    end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end
-----------------------------------------------------------------

local function OnHealthDelta(inst, data)
    local amount = data.amount
    if amount >= 0 then
        return
    end

    amount = -amount

    inst.damage_check = inst.damage_check + amount

    local afflicter = data.afflicter


    while inst.damage_check >= TUNING.STARILIAD_BOSS_GORGOROTH_RELEASE_BLOB_DAMAGE do
        local direction

        if afflicter and afflicter:IsValid() then
            direction = (afflicter:GetPosition() - inst:GetPosition()):GetNormalized()
            direction = StarIliadMath.RotateVector3(direction, Vector3(0, 1, 0), GetRandomMinMax(-30, 30))
        else
            direction = Vector3FromTheta(math.random() * PI2)
        end


        local speed = 3 + math.random() * 3

        local blob = SpawnAt("stariliad_boss_gorgoroth_blob", inst, nil, direction * (inst:GetPhysicsRadius(0) + 0.5))
        blob.components.entitytracker:TrackEntity("mainblob", inst)
        blob.sg:GoToState("spawn", { vel = direction * speed })

        inst.damage_check = inst.damage_check - TUNING.STARILIAD_BOSS_GORGOROTH_RELEASE_BLOB_DAMAGE
    end
end

local function AbsorbSmallBlob(inst)
    if not inst.components.health:IsDead() then
        inst.components.health:DoDelta(TUNING.STARILIAD_BOSS_GORGOROTH_BLOB_REGEN_HEALTH)
    end
end

local function OnNewTarget(inst)
    if inst.loss_target_music_task then
        inst.loss_target_music_task:Cancel()
        inst.loss_target_music_task = nil
    end

    inst:SetMusicLevel(2)
end

local function OnDroppedTarget(inst)
    if inst.loss_target_music_task then
        inst.loss_target_music_task:Cancel()
    end

    inst.loss_target_music_task = inst:DoTaskInTime(5, function()
        inst:SetMusicLevel(1)
        inst.loss_target_music_task = nil
    end)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeGiantCharacterPhysics(inst, 1000, 3)

    inst.AnimState:SetBank("crick_crickantqueen")
    inst.AnimState:SetBuild("stariliad_boss_gorgoroth")
    inst.AnimState:PlayAnimation("idle", true)

    -- inst.AnimState:AddOverrideBuild("stariliad_boss_gorgoroth_head")
    inst.AnimState:OverrideSymbol("crick_headbase", "stariliad_boss_gorgoroth_head", "crick_headbase")
    -- inst.AnimState:OverrideSymbol("crick_headbase", "stariliad_boss_gorgoroth_head", "head_large")
    inst.AnimState:HideSymbol("crick_antenna")
    inst.AnimState:HideSymbol("crick_crown")
    inst.AnimState:HideSymbol("crick_eye1")
    inst.AnimState:HideSymbol("crick_eye2")
    inst.AnimState:SetSymbolMultColour("fx_bits", 0, 0, 0, 1)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("shadow_aligned")

    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_gorgoroth")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_GORGOROTH_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_BOSS_GORGOROTH_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.STARILIAD_BOSS_GORGOROTH_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetOnHit(OnHit)
    inst.components.combat:SetHurtSound("rifts4/goop/hit_big")
    inst.components.combat.playerdamagepercent = TUNING.STARILIAD_BOSS_GORGOROTH_PLAYERDAMAGEPERCENT

    inst:AddComponent("planarentity")

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.STARILIAD_BOSS_GORGOROTH_PLANAR_DAMAGE)

    -- Almost immune to planar damage
    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(9999)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_BOSS_GORGOROTH_HEALTH)
    inst.components.health.destroytime = 8

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_boss_gorgoroth")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(40)

    inst:AddComponent("knownlocations")

    inst:AddComponent("explosiveresist")

    -- MakeLargeBurnableCharacter(inst, "crick_torso")

    ----------------------------------------------------------
    inst.damage_check = 0
    inst.SpawnTrails = SpawnTrails
    inst.DoPoundDamage = DoPoundDamage
    inst.ShakeItems = ShakeItems
    inst.CheckHopCooldown = CheckHopCooldown
    inst.GenerateSpitPos = GenerateSpitPos
    -- inst.Absorb = AbsorbSmallBlob

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    ----------------------------------------------------------

    inst:SetStateGraph("SGstariliad_boss_gorgoroth")
    inst:SetBrain(brain)

    inst:DoTaskInTime(1, function()
        inst.components.knownlocations:RememberLocation("home", inst:GetPosition(), true)
    end)

    -- inst:ListenForEvent("healthdelta", OnHealthDelta)
    -- inst:ListenForEvent("absorb_blob", AbsorbSmallBlob)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    return inst
end

-----------------------------------------------------------------

-- local LEFT_PROPS =
-- {
--     "prop_eyes_L1",
--     "prop_eyes_L2",
--     "prop_horns_L1",
--     "prop_teeth_L1",
--     "prop_teeth_L2",
--     "prop_teeth_L3",
-- }

-- local RIGHT_PROPS =
-- {
--     "prop_eyes_R1",
--     "prop_eyes_R2",
--     "prop_horns_R1",
--     "prop_horns_R2",
--     "prop_teeth_R1",
--     "prop_teeth_R2",
--     "prop_teeth_R3",
-- }

local GELBLOB_OPTIONAL_SYMBOLS = {
    "prop_eyes_L1",
    "prop_eyes_L2",
    "prop_horns_L1",
    "prop_teeth_L1",
    "prop_teeth_L2",
    "prop_teeth_L3",

    "prop_eyes_R1",
    "prop_eyes_R2",
    "prop_horns_R1",
    "prop_horns_R2",
    "prop_teeth_R1",
    "prop_teeth_R2",
    "prop_teeth_R3",
}

local function StartMeteor(inst, no_warning_time, has_warning_time)
    local collide_time = 8 * FRAMES

    inst:DoTaskInTime(no_warning_time, function()
        local shadow = SpawnAt("stariliad_meteor_shadow", inst)
        shadow:StartFX(has_warning_time)
    end)

    inst:DoTaskInTime(no_warning_time + has_warning_time - collide_time, function()
        -- inst.Transform:SetRotation(math.random() * 360)

        -- inst.AnimState:PlayAnimation("egg_crash_pre")
        -- inst.AnimState:PushAnimation("egg_crash", false)

        inst.AnimState:PlayAnimation("idle")
    end)

    inst:DoTaskInTime(no_warning_time + has_warning_time, function()
        -- inst.components.groundpounder:GroundPound()

        -- inst.SoundEmitter:PlaySound("rifts4/goop/spawn")

        -- ShakeAllCameras(CAMERASHAKE.FULL, 0.5, 0.03, .6, inst, 40)

        local hit_fx = SpawnAt("stariliad_boss_gorgoroth_meteor_hit", inst)
        for i, v in ipairs(inst.gelblob_hidden_symbols) do
            hit_fx.AnimState:HideSymbol(v)
        end

        -- Spawn trails and slowdown
        SpawnTrails(inst,
            nil,
            TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_TRAIL_RADIUS,
            math.random(unpack(TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_TRAIL_NUMS)),
            TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_TRAIL_DURATION,
            TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_TRAIL_DURATION_VAR)

        if inst.owner and inst.owner:IsValid() then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 4, nil, { "INLIMBO", "FX" })

            for _, v in pairs(ents) do
                if v.components.workable and v.components.workable:CanBeWorked() and v.components.workable.action ~= ACTIONS.NET then
                    v.components.workable:WorkedBy(inst.owner, TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_WORK_DAMAGE)
                elseif v.components.combat and inst.owner.components.combat and inst.owner.components.combat:CanTarget(v) then
                    inst.owner.components.combat:DoAttack(v, inst, nil, nil, nil, 99999)
                end
            end
        end


        inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/meteor_strike")
        inst.SoundEmitter:PlaySound("rifts4/goop/death")

        ShakeAllCameras(CAMERASHAKE.FULL, .5, .03, .25, inst, 30)
    end)
end

local function meteor_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    -- inst.Transform:SetFourFaced()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("meteor")
    inst.AnimState:SetBuild("meteor")
    -- inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetSymbolMultColour("rock01", 0, 0, 0, 0)

    for i = 0, 8 do
        local symbol_name = "wood_splinter" .. i

        -- inst.AnimState:OverrideSymbol(symbol_name, "meteor", math.random() < 0.5 and "1" or "2")

        inst.AnimState:SetSymbolMultColour(symbol_name, 0, 0, 0, 0.5)
    end

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.anim = inst:SpawnChild("stariliad_boss_gorgoroth_meteor_anim")
    inst.anim.entity:AddFollower()
    inst.anim.Follower:FollowSymbol(inst.GUID, "rock01", 0, 7.2, 0, true)

    inst.gelblob_hidden_symbols = {}
    for i, v in ipairs(GELBLOB_OPTIONAL_SYMBOLS) do
        if math.random() < 0.5 then
            inst.anim.AnimState:HideSymbol(v)
            table.insert(inst.gelblob_hidden_symbols, v)
        end
    end

    inst.StartMeteor = StartMeteor

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.STARILIAD_BOSS_GORGOROTH_METEOR_DAMAGE)

    -- inst:ListenForEvent("animover", function()
    --     if inst.AnimState:IsCurrentAnimation("egg_crash_pre") then
    --         inst.AnimState:HideSymbol("rock01")
    --     elseif inst.AnimState:IsCurrentAnimation("egg_crash") then
    --         inst:Remove()
    --     end
    -- end)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function meteor_anim_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gelblob")
    inst.AnimState:SetBuild("stariliad_gelblob_meteor")
    inst.AnimState:SetPercent("spawn_big", 1177 / 2475)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

--------------------------------------------------------------------



local function meteor_hit_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gelblob")
    inst.AnimState:SetBuild("gelblob")
    inst.AnimState:PlayAnimation("death_small")
    inst.AnimState:SetFinalOffset(7)
    inst.AnimState:Hide("BACK")
    inst.AnimState:Hide("backpack")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst.back = inst:SpawnChild("gelblob_back_fx")
    -- inst.back.AnimState:PlayAnimation("death_small")


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-------------------------------------------------------------------------------------------


local function spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()


    -- inst.AnimState:SetBank("rabbithole")
    -- inst.AnimState:SetBuild("rabbit_hole")
    -- inst.AnimState:PlayAnimation("idle")
    -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
    -- inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("spawner")
    inst.components.spawner:Configure("stariliad_boss_gorgoroth", TUNING.TOTAL_DAY_TIME)
    inst.components.spawner:SetOnlySpawnOffscreen(true)

    return inst
end

return Prefab("stariliad_boss_gorgoroth", fn, assets),
    Prefab("stariliad_boss_gorgoroth_meteor", meteor_fn, assets),
    Prefab("stariliad_boss_gorgoroth_meteor_anim", meteor_anim_fn, assets),
    Prefab("stariliad_boss_gorgoroth_meteor_hit", meteor_hit_fn, assets),
    Prefab("stariliad_boss_gorgoroth_spawner", spawner_fn, assets)
