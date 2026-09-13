require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/eyeball_turret.zip"),
    Asset("ANIM", "anim/eyeball_turret_object.zip"),
    Asset("ANIM", "anim/eyeball_turret_base.zip"),

    -- Asset("MINIMAP_IMAGE", "eyeball_turret"),
}

SetSharedLootTable("stariliad_necrons_turret",
    {
        { 'thulecite',        1.00 },
        { 'thulecite',        0.75 },
        { 'thulecite_pieces', 1.00 },
        { 'thulecite_pieces', 0.75 },
        { 'thulecite_pieces', 0.50 },
        { 'thulecite_pieces', 0.25 },
    }
)

local brain = require "brains/stariliad_necrons_turret_brain"

local MAX_LIGHT_FRAME = 24

local function OnUpdateLight(inst, dframes)
    local frame = inst._lightframe:value() + dframes
    if frame >= MAX_LIGHT_FRAME then
        inst._lightframe:set_local(MAX_LIGHT_FRAME)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    if frame <= 20 then
        local k = frame / 20
        --radius:    0   -> 3.5
        --intensity: .65 -> .9
        --falloff:   .7  -> .9
        inst.Light:SetRadius(3.5 * k)
        inst.Light:SetIntensity(.9 * k + .65 * (1 - k))
        inst.Light:SetFalloff(.9 * k + .7 * (1 - k))
    else
        local k = (frame - 20) / (MAX_LIGHT_FRAME - 20)
        --radius:    3.5 -> 0
        --intensity: .9  -> .65
        --falloff:   .9  -> .7
        inst.Light:SetRadius(3.5 * (1 - k))
        inst.Light:SetIntensity(.65 * k + .9 * (1 - k))
        inst.Light:SetFalloff(.7 * k + .9 * (1 - k))
    end

    if TheWorld.ismastersim then
        inst.Light:Enable(frame < MAX_LIGHT_FRAME)
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function TriggerLight(inst)
    inst._lightframe:set(0)
    OnLightDirty(inst)
end

local function LaunchLaserClient(inst, target_pos)
    local seg_dist = 1.0
    local start_offset = 1.0
    local end_offset = -1.5
    local depth_enable_range = 2.0

    local start_x, start_y, start_z = inst.AnimState:GetSymbolPosition("eye")
    local start_pos = Vector3(start_x, start_y, start_z)
    local delta = target_pos - start_pos

    local dir = delta:GetNormalized()
    local dist = delta:Length()

    if dist > 40 then
        print(inst, "Too long laser:", dist)
        return
    end

    local stop_dist = dist + end_offset

    for cur_dist = start_offset, stop_dist, seg_dist do
        local cur_pos = start_pos + dir * cur_dist

        local segment = SpawnAt("stariliad_necrons_turret_laser_segment", cur_pos)
        if cur_dist > stop_dist - depth_enable_range then
            segment:SetGroundDepth()
        end
        segment:EmitFX(dir)
    end
end

---------------------------------------------------------------------------------------------

local function RetargetFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.STARILIAD_NECRONS_TURRET_ATTACK_RANGE, { "_combat" },
        { "INLIMBO", "stariliad_necrons" })
    for i, v in ipairs(ents) do
        if inst.components.combat:CanTarget(v) then
            if v.components.combat:TargetIs(inst) then
                return v
            end

            if v:HasOneOfTags({ "player", "character", "largecreature" }) then
                return v
            end

            return v
        end
    end
end

local function shouldKeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and inst:IsNear(target, TUNING.STARILIAD_NECRONS_TURRET_ATTACK_RANGE)
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, 15, function(dude)
            return dude:HasTag("stariliad_necrons")
        end, 10)
    end
end

-- local function EquipWeapon(inst)
--     if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
--         local weapon = CreateEntity()
--         --[[Non-networked entity]]
--         weapon.entity:AddTransform()
--         weapon:AddComponent("weapon")
--         weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
--         weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange + 4)
--         weapon.components.weapon:SetProjectile("eye_charge")
--         weapon:AddComponent("inventoryitem")
--         weapon.persists = false
--         weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
--         weapon:AddComponent("equippable")

--         inst.components.inventory:Equip(weapon)
--     end
-- end

local function SyncAnim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
    inst.base.AnimState:PlayAnimation(animname, loop)
end

local function SyncPushAnim(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
    inst.base.AnimState:PushAnimation(animname, loop)
end

local function SpawnOpenFireFX(inst)
    local fx = inst:SpawnChild("stariliad_necrons_turret_openfire_fx")
end

local function LaunchLaserServer(inst, target_pos)
    inst._launch_laser_pos_x:set(target_pos.x)
    inst._launch_laser_pos_y:set(target_pos.y)
    inst._launch_laser_pos_z:set(target_pos.z)
    inst._launch_laser_event:push()

    -- inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")

    local hit_sound = SpawnAt("stariliad_necrons_turret_hit_sound", target_pos)

    inst:DoTaskInTime(0, function()
        local hit_fx = SpawnAt("stariliad_necrons_turret_laser_hit_fx", target_pos)
    end)
end

-- local function LaunchProjectile(inst, target, target_pos)
--     local aim_pos = target_pos and target:GetPosition() or target_pos

--     local projectile = SpawnAt("eye_charge", inst)
--     projectile:AddComponent("weapon")
--     projectile.components.weapon:SetDamage(inst.components.combat.defaultdamage)
--     projectile.components.projectile:Throw(inst, target, inst)

--     -- local fx = SpawnAt("stariliad_necrons_turret_openfire_fx", inst)
--     -- fx.Transform:SetRotation(inst.Transform:GetRotation())
-- end

local function DoDamage(inst, target_pos)
    local ents = TheSim:FindEntities(target_pos.x, target_pos.y, target_pos.z, 1.0, { "_combat" },
        { "INLIMBO", "stariliad_necrons" })

    for _, v in pairs(ents) do
        if inst.components.combat:CanTarget(v) then
            inst.components.combat:DoAttack(v, nil, nil, nil, nil, math.huge)
        end
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
    inst:SetPhysicsRadiusOverride(1)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.Transform:SetFourFaced()

    -- inst.MiniMapEntity:SetIcon("eyeball_turret.png")

    inst:AddTag("stariliad_necrons")
    inst:AddTag("structure")

    inst.AnimState:SetBank("eyeball_turret")
    inst.AnimState:SetBuild("eyeball_turret")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(43 / 255, 242 / 255, 31 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(1.5)
    inst.Light:Enable(false)

    inst._lightframe = net_smallbyte(inst.GUID, "eyeturret._lightframe", "lightdirty")
    inst._lighttask = nil

    inst._launch_laser_pos_x = net_float(inst.GUID, "inst._launch_laser_pos_x")
    inst._launch_laser_pos_y = net_float(inst.GUID, "inst._launch_laser_pos_y")
    inst._launch_laser_pos_z = net_float(inst.GUID, "inst._launch_laser_pos_z")
    inst._launch_laser_event = net_event(inst.GUID, "inst._launch_laser_event")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        inst:ListenForEvent("inst._launch_laser_event", function()
            LaunchLaserClient(inst, Vector3(inst._launch_laser_pos_x:value(), inst._launch_laser_pos_y:value(),
                inst._launch_laser_pos_z:value()))
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_NECRONS_TURRET_HEALTH)
    -- inst.components.health:StartRegen(TUNING.EYETURRET_REGEN, 1)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.STARILIAD_NECRONS_TURRET_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_NECRONS_TURRET_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_NECRONS_TURRET_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    -- inst.components.combat:SetShouldAggroFn(ShouldAggro)
    inst.components.combat.playerdamagepercent = TUNING.STARILIAD_NECRONS_TURRET_PLAYERDAMAGEPERCENT

    -- inst:AddComponent("inventory")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("stariliad_necrons_turret")
    inst.components.lootdropper.droprecipeloot = false

    MakeLargeFreezableCharacter(inst)
    MakeHauntableFreeze(inst)

    inst.base = inst:SpawnChild("stariliad_necrons_turret_base")
    inst.highlightchildren = { inst.base }

    -- inst.triggerlight = triggerlight
    inst.override_combat_fx_height = "low"
    inst.SyncAnim = SyncAnim
    inst.SyncPushAnim = SyncPushAnim
    inst.SpawnOpenFireFX = SpawnOpenFireFX
    inst.LaunchLaserServer = LaunchLaserServer
    -- inst.LaunchProjectile = LaunchProjectile
    inst.DoDamage = DoDamage
    inst.TriggerLight = TriggerLight

    inst:SetStateGraph("SGstariliad_necrons_turret")
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    -- inst:DoTaskInTime(FRAMES, EquipWeapon)

    return inst
end

-----------------------------------------------------------------

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        parent.highlightchildren = { inst }
    end
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("eyeball_turret_base")
    inst.AnimState:SetBuild("eyeball_turret_base")
    inst.AnimState:PlayAnimation("idle_loop")

    inst:AddTag("DECOR")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
        return inst
    end

    return inst
end

-----------------------------------------------------------------

local function openfire_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bishop")
    inst.AnimState:SetBuild("bishop_build")
    inst.AnimState:PlayAnimation("atk2_pst")

    local hide_symbols = {
        "bulb",
        "eye",
        "eyelid",
        "face",
        "foot",
        "hips",
        "key",
        "leg_low",
        "leg_up",
        "neck",
        "shoulder",
        "waist",
        "wing",
    }

    for _, symbol in ipairs(hide_symbols) do
        inst.AnimState:HideSymbol(symbol)
    end

    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetMultColour(43 / 255, 242 / 255, 31 / 255, 1)
    inst.AnimState:SetDeltaTimeMultiplier(0.75)

    inst.AnimState:SetLightOverride(1)

    inst:Hide()

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(function(inst)
            local parent = inst.entity:GetParent()
            if parent then
                if inst._get_parent_time == nil then
                    inst._get_parent_time = GetTime()
                elseif GetTime() - inst._get_parent_time > FRAMES then
                    inst:Show()
                end

                local facing = parent.AnimState:GetCurrentFacing()
                if facing == FACING_LEFT or facing == FACING_RIGHT then
                    inst.Follower:FollowSymbol(parent.GUID, "eye", -200, 190, 0)
                else
                    inst.Follower:FollowSymbol(parent.GUID, "eye", 0, 180, 0)
                end
            end
        end)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-----------------------------------------------------------------

local function laser_hit_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("bomb_lunarplant")
    inst.AnimState:SetBuild("bomb_lunarplant")
    inst.AnimState:PlayAnimation("used")

    inst.AnimState:SetDeltaTimeMultiplier(1.3)

    -- inst.AnimState:SetSymbolBloom("light_beam")
    -- inst.AnimState:SetSymbolBloom("pb_energy_loop")
    -- inst.AnimState:SetSymbolLightOverride("light_beam", 1)
    -- inst.AnimState:SetSymbolLightOverride("pb_energy_loop", 1)
    -- inst.AnimState:OverrideSymbol("sleepcloud_pre", "sleepcloud", "sleepcloud_pre")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:HideSymbol("bombbreak")
    inst.AnimState:HideSymbol("splash_fx")

    inst.AnimState:SetMultColour(0, 1, 0, 1)

    -- local s = 1.3
    -- inst.AnimState:SetScale(s, s, s)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, function()
        -- inst.SoundEmitter:PlaySound("rifts/lunarthrall_bomb/explode")
        -- inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
    end)

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

-----------------------------------------------------------------

local function hit_sound_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
    end)

    return inst
end

return Prefab("stariliad_necrons_turret", fn, assets),
    Prefab("stariliad_necrons_turret_base", basefn, assets),
    Prefab("stariliad_necrons_turret_openfire_fx", openfire_fx_fn, assets),
    Prefab("stariliad_necrons_turret_laser_hit_fx", laser_hit_fx_fn, assets),
    Prefab("stariliad_necrons_turret_hit_sound", hit_sound_fn, assets)
