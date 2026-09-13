local assets =
{
    Asset("ANIM", "anim/tentacle.zip"),
    Asset("ANIM", "anim/mole_move_fx.zip"),
    Asset("ANIM", "anim/stariliad_dirt_fx_small.zip"),
}



local function CreateDirt(symbol)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stariliad_dirt_fx_small")
    inst.AnimState:SetBuild("stariliad_dirt_fx_small")
    inst.AnimState:PlayAnimation("dynamic", true)
    inst.AnimState:SetDeltaTimeMultiplier(1.2)

    if symbol then
        inst.AnimState:OverrideSymbol("1", "stariliad_dirt_fx_small", tostring(symbol))
    end

    local scale_start = 1
    local scale_end = 0.6
    local scale_duration = GetRandomMinMax(1.5, 2)
    inst.Transform:SetScale(scale_start, scale_start, scale_start)

    inst.task_time = GetTime()

    inst.task2 = inst:DoPeriodicTask(0, function()
        local duration = GetTime() - inst.task_time
        if duration > scale_duration then
            inst:Remove()
            return
        end

        local scale = Remap(duration, 0, scale_duration, scale_start, scale_end)
        inst.Transform:SetScale(scale, scale, scale)
    end)

    inst.task = inst:DoPeriodicTask(0, function()
        local x, y, z = inst:GetPosition():Get()
        local gravity = 40
        local vx, vy, vz = inst.Physics:GetMotorVel()
        vy = vy - gravity * FRAMES
        inst.Physics:SetMotorVel(vx, vy, vz)

        if y <= 0.05 and vy <= 0 then
            inst.Transform:SetPosition(x, 0, z)
            inst.Physics:Stop()
            inst.AnimState:Pause()
            inst.task:Cancel()
        end
    end)

    return inst
end

local function EmitDirtFX(inst)
    local pos = inst:GetPosition()

    if inst._last_pos == nil then
        inst._last_pos = pos
        return
    end

    if (pos - inst._last_pos):Length() > 0.3 then
        local spawn_sphere = CreateSphereEmitter(0.5)

        for i = 2, 3 do
            local spawn_offset = Vector3(spawn_sphere())
            local mypos = inst:GetPosition()
            spawn_offset.y = GetRandomMinMax(0.5, 0.8)

            local symbols = { 3, 4, 5 }
            local dirt = CreateDirt(GetRandomItem(symbols))
            dirt.Transform:SetPosition((mypos + spawn_offset):Get())
            dirt:ForceFacePoint((mypos + spawn_offset * 2):Get())

            local vx_init = GetRandomMinMax(0, 1)
            -- local vy_init = GetRandomMinMax(15, 23)
            local vy_init = GetRandomMinMax(10, 15)
            dirt.Physics:SetMotorVel(vx_init, vy_init, 0)
        end

        inst._last_pos = pos
    end
end


local function CheckMoveFX(inst)
    local pos = inst:GetPosition()

    if inst.last_pos == nil then
        inst.last_pos = pos
        return
    end

    if (pos - inst.last_pos):Length() > 0.45 then
        SpawnAt("stariliad_wriggler_tentacle_move_fx", inst).AnimState:SetTime(5 * FRAMES)
        -- SpawnAt("stariliad_wriggler_tentacle_move_fx", inst)

        inst.last_pos = pos
    end
end

local function RetargetFn(inst)
    return FindEntity(inst, 30, function(target)
            return inst.components.combat:CanTarget(target)
                and not inst.components.combat:IsAlly(target)
        end,
        { "_combat", "_health" },
        { "INLIMBO", "prey", "smallcreature", "tentacle" }
    )
end

local function shouldKeepTarget(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        local should_share = dude.prefab == "stariliad_wriggler_tentacle" and not dude.components.health:IsDead()
        return should_share
    end, 10)
end

local function OnStateChange(inst, data)
    if inst.sg:HasStateTag("moving") and not inst.SoundEmitter:PlayingSound("moving") then
        -- inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/toad_parasite/tentacle_moving2", "moving")
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/move", "moving")
    elseif not inst.sg:HasStateTag("moving") and inst.SoundEmitter:PlayingSound("moving") then
        inst.SoundEmitter:KillSound("moving")
    end

    inst.Physics:SetActive(inst.sg:HasStateTag("should_physics") or inst.sg:HasStateTag("moving"))
end

local function DropLootFn(lootdropper)
    local inst = lootdropper.inst
    local index = inst.loot_index or math.random(1, 4)

    print(inst, "Dropping loot for index: ", index)
    lootdropper:AddChanceLoot("stariliad_shroom_skin_part_" .. tostring(index), 1)
end

local function OnSave(inst, data)
    data.loot_index = inst.loot_index
end

local function OnLoad(inst, data)
    if data ~= nil and data.loot_index ~= nil then
        inst.loot_index = data.loot_index
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, 0.25)

    inst.AnimState:SetBank("tentacle")
    inst.AnimState:SetBuild("tentacle")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("wet")
    inst:AddTag("tentacle")
    inst:AddTag("epic")
    inst:AddTag("noepicmusic")

    StarIliadBasic.AddTriggeredEventMusic(inst, "stariliad_boss_toad_parasite")

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(EmitDirtFX)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.loot_index = nil

    inst.components.updatelooper:AddOnUpdateFn(CheckMoveFX)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.STARILIAD_WRIGGLER_TENTACLE_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.STARILIAD_WRIGGLER_TENTACLE_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_WRIGGLER_TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.STARILIAD_WRIGGLER_TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), RetargetFn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)

    -- MakeLargeFreezableCharacter(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(DropLootFn)

    inst:AddComponent("knownlocations")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    local brain = require("brains/stariliad_wriggler_tentacle_brain")
    inst:SetStateGraph("SGstariliad_wriggler_tentacle")
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newstate", OnStateChange)

    inst:SetMusicLevel(3)



    return inst
end

-----------------------------------------------------------------------------------------------------------

local function OnProjectileHit(inst)
    if not inst:IsOnPassablePoint(false) then
        inst:Remove()
        return
    end

    for _, v in pairs(AllPlayers) do
        if not IsEntityDeadOrGhost(v, true) and inst:IsNear(v, 40) then
            SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["playsound"], v.userid,
                "stariliad_sfx/prefabs/toad_parasite/death_deng_2d")
        end
    end

    local tentacle = SpawnAt("stariliad_wriggler_tentacle", inst)
    tentacle.sg:GoToState("attack")

    tentacle.loot_index = inst.loot_index

    tentacle:SetMusicLevel(1)
    tentacle:DoTaskInTime(0.8, function()
        tentacle:SetMusicLevel(3)
    end)

    if inst.start_with_normal_attack then
        tentacle.components.combat:ResetCooldown()
        tentacle.last_dash_time = GetTime()
    end

    tentacle.components.knownlocations:RememberLocation("home", Point(inst.Transform:GetWorldPosition()), true)

    tentacle.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_land")


    inst.AnimState:PlayAnimation("land")
    inst:ListenForEvent("animover", inst.Remove)
end

local function spawn_project_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("mushroombomb")
    inst.AnimState:SetBuild("mushroombomb")
    inst.AnimState:PlayAnimation("projectile_loop", true)

    inst.AnimState:HideSymbol("mushroom_pieces")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)


    return inst
end

local function move_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("mole_fx")
    inst.AnimState:SetBuild("mole_move_fx")
    inst.AnimState:PlayAnimation("move")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("stariliad_wriggler_tentacle", fn, assets),
    Prefab("stariliad_wriggler_tentacle_spawn_project", spawn_project_fn, assets),
    Prefab("stariliad_wriggler_tentacle_move_fx", move_fx_fn, assets)
