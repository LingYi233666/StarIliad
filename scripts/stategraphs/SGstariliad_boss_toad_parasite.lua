require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnElectrocute(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFallInVoid(),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            -- inst.sg:GoToState("attack")

            if inst.sg.mem.last_attack == "pound" or inst.sg.mem.last_attack == nil then
                inst.sg:GoToState("attack_emit_worms_pre")
                inst.sg.mem.last_attack = "emit_worms"
            else
                inst.sg:GoToState("attack_pound_pre", { num_to_pound = 4 })
                inst.sg.mem.last_attack = "pound"
            end
        end
    end),
    EventHandler("attacked", function(inst, data)
        if inst.components.health and not inst.components.health:IsDead() then
            if CommonHandlers.TryElectrocuteOnAttacked(inst, data) then
                return
            elseif (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
                not CommonHandlers.HitRecoveryDelay(inst)
            then
                inst.sg:GoToState("hit")
            end
        end
    end),
}


local function DoFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
    -- ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, .7, inst, 40)
end

local function DoStompstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, .7, inst, 40)
    -- DestroyStuff(inst)
    -- BounceStuff(inst)
end

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .5, inst, 40)
    -- BounceStuff(inst)
end

local function DoPoundShake(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .35, .02, 1, inst, 40)
    -- BounceStuff(inst)
end

local function DoRoarShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
    -- BounceStuff(inst)
end

-----------------------------------------------------------------------------------------------

local function ClearWormsFX(inst)
    if inst.sg.mem.worms then
        for _, worm in pairs(inst.sg.mem.worms) do
            worm:Remove()
        end
    end

    inst.sg.mem.worms = {}
end

local function SpawnWormsFX(inst)
    ClearWormsFX(inst)

    -- local mx, my, mz = inst.Transform:GetWorldPosition()

    -- local radius = 2
    -- local num_worms_emitter = 3

    -- for angle = 0, 360, 360 / num_worms_emitter do
    --     local fine_tune_angle = GetRandomMinMax(-10, 10) + angle

    --     -- in inst coordinate
    --     local x = radius * math.cos(fine_tune_angle * DEGREES)
    --     local y = GetRandomMinMax(3, 4)
    --     local z = radius * math.sin(fine_tune_angle * DEGREES)

    --     local worm = inst:SpawnChild("stariliad_parasite_worm_fx")
    --     worm.Transform:SetPosition(x, y, z)

    --     local wx, wy, wz = inst.entity:LocalToWorldSpace(x, y, z)
    --     local delta = Vector3(wx - mx, wy - my, wz - mz)
    --     delta.y = 0
    --     delta = delta:GetNormalized() * 0.2

    --     worm._vx:set(delta.x)
    --     worm._vy:set(GetRandomMinMax(0.15, 0.25))
    --     worm._vz:set(delta.z)

    --     table.insert(inst.sg.mem.worms, worm)
    -- end

    -- inst.sg.mem.worms = {}
    -- for i = 1, 3 do
    --     local worm = inst:SpawnChild("stariliad_parasite_worm_fx")
    --     worm.entity:AddFollower()
    --     table.insert(inst.sg.mem.worms, worm)
    -- end

    -- Side hole
    local worm_side_hole = inst:SpawnChild("stariliad_parasite_worm_fx_side_hole")
    worm_side_hole.entity:AddFollower()
    worm_side_hole.Follower:FollowSymbol(inst.GUID, "toad_gland", 0, 0, 0, true, nil, 2)

    -- Side body
    local worm_side_body = inst:SpawnChild("stariliad_parasite_worm_fx_side_body")
    worm_side_body.entity:AddFollower()
    -- worm_side_body.Follower:FollowSymbol(inst.GUID, "toad_torso", 280, -350, 0, true, nil, 0)
    worm_side_body.Follower:FollowSymbol(inst.GUID, "toad_torso", 360, -250, 0, true, nil, 0)

    -- mouth
    local worm_side_mouth = inst:SpawnChild("stariliad_parasite_worm_fx_side_mouth")
    worm_side_mouth.entity:AddFollower()
    worm_side_mouth.Follower:FollowSymbol(inst.GUID, "toad_mouth", -180, -80, 0, true, nil, 2)

    -- Up body
    local worm_up_body = inst:SpawnChild("stariliad_parasite_worm_fx_up_body")
    worm_up_body.entity:AddFollower()
    worm_up_body.Follower:FollowSymbol(inst.GUID, "toad_torso", -12, -340, 0, true, nil, 0)

    table.insert(inst.sg.mem.worms, worm_side_hole)
    table.insert(inst.sg.mem.worms, worm_side_body)
    table.insert(inst.sg.mem.worms, worm_side_mouth)
    table.insert(inst.sg.mem.worms, worm_up_body)
end

local function StopWormsInfect(inst)
    if inst.sg.mem.infect_task then
        inst.sg.mem.infect_task:Cancel()
    end
    inst.sg.mem.infect_task = nil
    inst.sg.mem.infect_victims = {}
end

local function StartWormsInfect(inst)
    StopWormsInfect(inst)

    inst.sg.mem.infect_task = inst:DoPeriodicTask(0, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_EMIT_WORMS_RANGE,
            { "_combat", "_health" }, { "INLIMBO" })
        for _, v in pairs(ents) do
            if inst.components.combat:CanTarget(v) and not inst.components.combat:IsAlly(v) then
                if v.components.inventory then
                    if inst.sg.mem.infect_victims[v] == nil or GetTime() - inst.sg.mem.infect_victims[v] > 0.44 then
                        inst.sg.mem.infect_victims[v] = GetTime()
                        -- Spawn infect to victim's inventory
                        local curse = SpawnAt("stariliad_curse_toad_parasite_infect", v)
                        if StarIliadBasic.ForceGiveItem(v, curse) then
                            v:PushEvent("attacked", { attacker = inst, damage = 0 })
                        elseif curse:IsValid() then
                            curse:Remove()
                        end
                    end
                else
                    if inst.sg.mem.infect_victims[v] == nil or GetTime() - inst.sg.mem.infect_victims[v] > 0.1 then
                        inst.sg.mem.infect_victims[v] = GetTime()

                        inst.components.combat:SetDefaultDamage(TUNING
                            .STARILIAD_BOSS_TOAD_PARASITE_ATTACK_EMIT_WORMS_DAMAGE)
                        inst.components.combat:DoAttack(v, nil, nil, nil, nil, 99999)
                        inst.components.combat:SetDefaultDamage(TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_POUND_DAMAGE)
                    end
                end
            end
        end
    end)
end

local function TryMoveToTarget(inst)
    inst.components.locomotor:Stop()

    local target = inst.components.combat.target
    if target and target:IsValid() then
        local target_pos = target:GetPosition()
        local inst_pos = inst:GetPosition()
        local distance = (target_pos - inst_pos):Length()
        -- local dir = (target_pos - inst_pos):GetNormalized()
        -- local velocity = dir * TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_POUND_MOVING_SPEED

        -- inst.Physics:SetVel(velocity.x, 0, velocity.z)

        local min_distance = inst:GetPhysicsRadius(0)
        local max_distance = min_distance + 4
        local speed = Remap(math.clamp(distance, min_distance, max_distance), min_distance, max_distance, 0.1,
            TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_POUND_MOVING_SPEED)

        inst:ForceFacePoint(target_pos)
        inst.Physics:SetMotorVel(speed, 0, 0)
        -- inst.Physics:SetMotorVelOverride(TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_POUND_MOVING_SPEED, 0, 0)
    end
end

local states =
{
    State {
        name = "spawn",
        tags = { "busy", "nosleep", "nofreeze", "noattack", "noelectrocute" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("spawn_appear_toad")
            inst.DynamicShadow:Enable(false)
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spawn_appear_pre")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 40 * FRAMES, .03, 2, inst, 40)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spawn_appear")
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(31 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/dustpoof")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
        end,
    },

    State {
        name = "roar",
        tags = { "roar", "busy", "nosleep", "nofreeze", "noelectrocute" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("phase_transition")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar_phase")
                DoRoarShake(inst)
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(21 * FRAMES, DoRoarShake),
            TimeEvent(22 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },


    State {
        name = "attack_emit_worms_pre",
        tags = { "busy", },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_channeling_pre")
            inst.AnimState:HideSymbol("glow_yellow")

            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/toad_parasite/emit_worms")

                inst.sg:AddStateTag("attack")
                SpawnWormsFX(inst)
            end),

            TimeEvent(14 * FRAMES, ShakeIfClose),

            TimeEvent(16 * FRAMES, function(inst)
                StartWormsInfect(inst)
            end),

        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.state_normal_over = true
                    inst.sg:GoToState("attack_emit_worms")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ShowSymbol("glow_yellow")

            if not inst.sg.statemem.state_normal_over then
                ClearWormsFX(inst)
                StopWormsInfect(inst)
            end
        end,
    },

    State {
        name = "attack_emit_worms",
        tags = { "busy", "attack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_channeling_loop", true)
            inst.AnimState:HideSymbol("glow_yellow")

            inst.sg.statemem.channelshaketask = inst:DoPeriodicTask(inst.AnimState:GetCurrentAnimationLength(),
                function()
                    ShakeAllCameras(CAMERASHAKE.VERTICAL, 6 * FRAMES, .02, .2, inst, 40)
                end
            )
            inst.sg.statemem.worms = {}

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "attack_channeling_pst")
        end,

        timeline = {
            TimeEvent(0 * FRAMES, function(inst)

            end),
        },

        events =
        {

        },

        onexit = function(inst)
            inst.AnimState:ShowSymbol("glow_yellow")

            if inst.sg.statemem.channelshaketask then
                inst.sg.statemem.channelshaketask:Cancel()
            end

            ClearWormsFX(inst)
            StopWormsInfect(inst)
        end,
    },

    -- c_findnext("stariliad_boss_toad_parasite").sg:GoToState("attack_pound_pre", { num_to_pound = 3 })
    State {
        name = "attack_pound_pre",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze", "noelectrocute", "overridelocomote" },

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack_pound_pre")

            data = data or {}
            inst.sg.mem.num_to_pound = data.num_to_pound or 1

            inst.components.combat:StartAttack()

            inst:StopBrain()
        end,

        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
            end),

            TimeEvent(13 * FRAMES, function(inst)
                TryMoveToTarget(inst)
            end),

            TimeEvent(36 * FRAMES, function(inst)
                DoPoundShake(inst)
                inst.components.groundpounder:GroundPound()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

                inst.Physics:Stop()
                -- inst.Physics:ClearMotorVelOverride()

                inst.sg.mem.num_to_pound = inst.sg.mem.num_to_pound - 1
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.num_to_pound > 0 then
                        inst.sg:GoToState("attack_pound_loop")
                    else
                        inst.sg:GoToState("attack_pound_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
        end,
    },

    State {
        name = "attack_pound_loop",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze", "noelectrocute", "overridelocomote" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_pound_loop")

            TryMoveToTarget(inst)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                DoPoundShake(inst)

                if TheWorld:HasTag("cave") then
                    TheWorld:PushEvent("ms_miniquake", { rad = 20, num = 20, duration = 2.5, target = inst })
                end

                inst.components.groundpounder:GroundPound()
                -- BounceStuff(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

                inst.Physics:Stop()
                -- inst.Physics:ClearMotorVelOverride()

                inst.sg.mem.num_to_pound = inst.sg.mem.num_to_pound - 1
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.num_to_pound > 0 then
                        inst.sg:GoToState("attack_pound_loop")
                    else
                        inst.sg:GoToState("attack_pound_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            -- inst.Physics:ClearMotorVelOverride()
        end,
    },

    State {
        name = "attack_pound_pst",
        tags = { "attack", "busy", "pounding", "nosleep", "nofreeze", "noelectrocute" },

        onenter = function(inst)
            inst:RestartBrain()

            inst.Physics:Stop()
            -- inst.Physics:ClearMotorVelOverride()

            inst.AnimState:PlayAnimation("attack_pound_pst")
        end,

        timeline =
        {
            CommonHandlers.OnNoSleepTimeEvent(5 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
                inst.sg:RemoveStateTag("noelectrocute")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State {
        name = "spawn_tentacles",
        tags = { "busy", },

        onenter = function(inst)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("corpse_hit", true)
            inst.AnimState:SetDeltaTimeMultiplier(3)

            inst.SoundEmitter:PlaySound("stariliad_sfx/prefabs/toad_parasite/death")

            -- TODO: Spawn some worm fx
        end,

        timeline =
        {
            TimeEvent(48 * FRAMES, function(inst)
                inst:SetMusicLevel(1)

                SpawnAt("stariliad_boss_toad_parasite_explode_fx_1", inst)
                SpawnAt("stariliad_boss_toad_parasite_explode_fx_2", inst)

                for i = 1, 4 do
                    local angle = GetRandomWithVariance(90 * i, 20) * DEGREES
                    local radius = GetRandomWithVariance(5, 2)
                    local targetpos = inst:GetPosition() + Vector3(radius * math.cos(angle), 0, radius * math.sin(angle))

                    local proj = SpawnAt("stariliad_wriggler_tentacle_spawn_project", inst)
                    proj.loot_index = i
                    proj.components.complexprojectile:Launch(targetpos, inst, inst)
                    if i == 1 or i == 3 then
                        proj.start_with_normal_attack = true
                    end
                end


                -- inst:Hide()
                inst:Remove()
            end),

            -- TimeEvent(3, function(inst)
            --     for _, v in pairs(AllPlayers) do
            --         if not IsEntityDeadOrGhost(v, true) then
            --             SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["playsound"], v.userid,
            --                 "stariliad_sfx/prefabs/toad_parasite/death_deng_2d")
            --         end
            --     end
            --     inst:Remove()
            -- end),
        },
    },
}

CommonStates.AddIdle(states, nil, "idle")

CommonStates.AddWalkStates(states,
    {
        starttimeline =
        {

        },
        walktimeline =
        {
            TimeEvent(0 * FRAMES, DoFootstep),
            TimeEvent(10 * FRAMES, DoStompstep),
            TimeEvent(19 * FRAMES, DoFootstep),
            TimeEvent(30 * FRAMES, DoStompstep),
        },
        endtimeline =
        {

        },
    },
    {
        walk = "walk",
    }
)

CommonStates.AddHitState(states, {
    TimeEvent(0 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/hit")
    end),
    TimeEvent(12 * FRAMES, function(inst)
        inst.sg:RemoveStateTag("busy")
    end),
})

CommonStates.AddDeathState(states, {
    TimeEvent(0 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/death")

        for _, v in pairs(inst.anchor_and_tentacles) do
            v.tentacle.AnimState:PlayAnimation("atk_pst")
            v.tentacle.AnimState:SetDeltaTimeMultiplier(1.5)
        end
    end),

    TimeEvent(4 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/channeling_LP", "channel")
    end),

    TimeEvent(23 * FRAMES, function(inst)
        inst.SoundEmitter:KillSound("channel")
    end),

    TimeEvent(24 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/roar")
    end),

    TimeEvent(35 * FRAMES, function(inst)
        ShakeIfClose(inst)
    end),

    TimeEvent(36 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/death_fall")
    end),

    TimeEvent(52 * FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/death_roar")
    end),

    TimeEvent(5, function(inst)
        inst.sg:GoToState("spawn_tentacles")
    end),
})

return StateGraph("SGstariliad_boss_toad_parasite", states, events, "idle")
