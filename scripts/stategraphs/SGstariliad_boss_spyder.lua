require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnAttacked(1),
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("attack")
        end
    end),
}

local function GetChargeDirection(inst, spawner, is_inverse)
    local my_pos = inst:GetPosition()
    local center = spawner:GetPosition()
    local vec = (my_pos - center):GetNormalized()
    local axis_y = Vector3(0, 1, 0)

    -- if is_inverse then
    --     return axis_y:Cross(vec):GetNormalized()
    -- end

    -- return vec:Cross(axis_y):GetNormalized()

    if is_inverse then
        return vec:Cross(axis_y):GetNormalized()
    end

    return axis_y:Cross(vec):GetNormalized()
end

local shinny_colors = {
    { 1, 1, 0, 1 },
    { 1, 0, 0, 1 },
    { 1, 0, 1, 1 },
    { 1, 0, 0, 1 },
}

local function ShinnyTask(inst)
    inst.AnimState:SetAddColour(unpack(shinny_colors[inst.shinny_flag]))

    inst.shinny_flag = inst.shinny_flag + 1
    if inst.shinny_flag > #shinny_colors then
        inst.shinny_flag = 1
    end
end

local function DoChargeAttack(inst, recent_tab)
    local search_range = inst:GetPhysicsRadius(0) + 3

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, search_range, nil, { "INLIMBO", "FX", "necron" })

    local success_hit = false
    local cur_time = GetTime()
    for _, v in pairs(ents) do
        if v:IsValid() and (recent_tab[v] == nil or cur_time - recent_tab[v] > 1) then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0) + 0.3 then
                if inst.components.combat:CanTarget(v) then
                    v.components.combat:GetAttacked(inst, TUNING.STARILIAD_BOSS_SPYDER_CHARGE_DAMAGE)

                    success_hit = true
                    recent_tab[v] = cur_time
                elseif v.components.workable ~= nil
                    and v.components.workable:CanBeWorked()
                    and v.components.workable.action ~= ACTIONS.NET then
                    SpawnAt("collapse_small", v)
                    v.components.workable:WorkedBy(inst, 30)

                    success_hit = true
                    recent_tab[v] = cur_time
                end
            end
        end
    end

    if success_hit then
        ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
    end
end

local states =
{
    -- State {
    --     name = "idle",
    --     tags = { "idle", "canrotate" },
    --     onenter = function(inst, playanim)
    --         inst.Physics:Stop()
    --         inst.AnimState:PlayAnimation("idle", true)
    --         if math.random() < .2 then
    --             inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
    --         end
    --     end,

    --     events =
    --     {
    --         EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    --     },
    -- },

    State {
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack")
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt")
            end),
            TimeEvent(28 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
            end),
            TimeEvent(28 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "charge_pre",
        tags = { "attack", "busy", "charge" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop", true)
            inst.AnimState:SetDeltaTimeMultiplier(10)

            inst.components.combat:StartAttack()

            inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/speed_burst", "speed_burst")

            ---------------------------------------------------------------
            inst.shinny_flag = 1
            if inst.shinny_task then
                inst.shinny_task:Cancel()
            end
            inst.shinny_task = inst:DoPeriodicTask(0.1, ShinnyTask)

            ---------------------------------------------------------------
            inst.sg.statemem.is_inverse = true

            local spawner = inst.components.entitytracker:GetEntity("spawner")
            if spawner and spawner:IsValid() then
                local dir = nil
                local target = inst.components.combat.target
                local positive_dir = GetChargeDirection(inst, spawner, false)
                local negative_dir = GetChargeDirection(inst, spawner, true)
                if target and target:IsValid() then
                    local towards = (target:GetPosition() - inst:GetPosition()):GetNormalized()
                    local angle = StarIliadMath.AngleBetweenVectors(towards, positive_dir, true)
                    if angle > -90 and angle < 90 then
                        inst.sg.statemem.is_inverse = false
                        dir = positive_dir
                    else
                        inst.sg.statemem.is_inverse = true
                        dir = negative_dir
                    end
                else
                    inst.sg.statemem.is_inverse = true
                    dir = negative_dir
                end

                inst:ForceFacePoint(inst:GetPosition() + dir)
            end

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            local in_radius, radius = inst:InChargeRadius()
            if in_radius then
                inst.sg.statemem.success_charge = true

                inst.sg:GoToState("charge", {
                    radius = radius,
                    max_angle = 720,
                    is_inverse = inst.sg.statemem.is_inverse,
                })
            else
                inst.sg:GoToState("idle", "walk_pst")
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.success_charge then
                inst.AnimState:SetDeltaTimeMultiplier(1)
                inst.SoundEmitter:KillSound("speed_burst")

                if inst.shinny_task then
                    inst.shinny_task:Cancel()
                    inst.shinny_task = nil
                end
                inst.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end,
    },

    State {
        name = "charge",
        tags = { "attack", "busy", "charge" },

        onenter = function(inst, data)
            inst.AnimState:PushAnimation("walk_loop", true)

            inst.sg.statemem.radius = data.radius
            inst.sg.statemem.max_angle = data.max_angle
            inst.sg.statemem.is_inverse = data.is_inverse

            inst.sg.statemem.cur_angle = 0
            inst.sg.statemem.last_pos = inst:GetPosition()

            inst.sg.statemem.fx = inst:SpawnChild("stariliad_boss_spyder_speed_burst_particle")

            inst.sg.statemem.recent_tab = {}
        end,

        onupdate = function(inst)
            local spawner = inst.components.entitytracker:GetEntity("spawner")
            if not (spawner and spawner:IsValid()) then
                inst.sg:GoToState("idle", "walk_pst")
                return
            end

            DoChargeAttack(inst, inst.sg.statemem.recent_tab)

            local center = spawner:GetPosition()
            local cur_pos = inst:GetPosition()
            local delta_angle = StarIliadMath.AngleBetweenVectors(cur_pos - center, inst.sg.statemem.last_pos - center,
                true)

            local dir = GetChargeDirection(inst, spawner, inst.sg.statemem.is_inverse)
            local speed = inst.components.locomotor.runspeed
            inst:ForceFacePoint(inst:GetPosition() + dir)

            inst.Physics:SetMotorVel(speed, 0, 0)

            inst.sg.statemem.cur_angle = inst.sg.statemem.cur_angle + math.abs(delta_angle)
            inst.sg.statemem.last_pos = cur_pos

            if inst.sg.statemem.cur_angle > inst.sg.statemem.max_angle then
                inst.sg:GoToState("idle", "walk_pst")
                return
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
            end),
        },

        onexit = function(inst)
            if inst.shinny_task then
                inst.shinny_task:Cancel()
                inst.shinny_task = nil
            end
            inst.AnimState:SetAddColour(0, 0, 0, 0)

            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.SoundEmitter:KillSound("speed_burst")
            if inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
                inst.sg.statemem.fx:Remove()
            end
        end,
    },

    State {
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/hurt")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.can_charge and inst:InChargeRadius() then
                    inst.can_charge = false
                    inst.sg:GoToState("charge_pre")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State {
        name = "birth",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, cb)
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_voice")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_foley")
        end,

        timeline =
        {
        },


        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "poop_pre",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("poop_pre")
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(
                    "dontstarve/creatures/spiderqueen/scream_short")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("poop_loop") end),
        },
    },

    State {
        name = "poop_loop",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            -- local angle = TheCamera:GetHeadingTarget() * DEGREES -- -22.5*DEGREES
            -- inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_loop")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(
                    "dontstarve/creatures/spiderqueen/givebirth_voice")
            end),

            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(
                    "dontstarve/creatures/spiderqueen/givebirth_foley")
            end),
            TimeEvent(10 * FRAMES, function(inst)
                -- if inst.components.incrementalproducer then
                --     inst.components.incrementalproducer:TryProduce()
                -- end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                -- if inst.components.incrementalproducer and inst.components.incrementalproducer:CanProduce() then
                --     inst.sg:GoToState("poop_loop")
                -- else
                --     inst.sg:GoToState("poop_pst")
                -- end

                inst.sg:GoToState("poop_pst")
            end),
        },
    },

    State {
        name = "poop_pst",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            -- local angle = TheCamera:GetHeadingTarget() * DEGREES -- -22.5*DEGREES
            -- inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_pst")
        end,
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst:DropDeathLoot()
        end,

        events =
        {

        },
    },
}

CommonStates.AddIdle(states, nil, "idle", {
    TimeEvent(0 * FRAMES,
        function(inst)
            if math.random() < .2 then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
            end
        end),
})

CommonStates.AddWalkStates(states,
    {
        walktimeline = {
            TimeEvent(0 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(7 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(10 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(13 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(17 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(25 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(32 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
            TimeEvent(38 * FRAMES,
                function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
        },
    })

CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)


return StateGraph("SGstariliad_boss_spyder", states, events, "idle")
