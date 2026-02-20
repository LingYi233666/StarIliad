require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnAttacked(),
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
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack")
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt")
            end),
            TimeEvent(28 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
            end),
            TimeEvent(28 * FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "charge_pre",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop", true)
            inst.AnimState:SetDeltaTimeMultiplier(10)

            inst.components.combat:StartAttack()

            inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/speed_burst", "speed_burst")

            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            local radius = 0

            local spawner = inst.components.entitytracker:GetEntity("spawner")
            if spawner and spawner:IsValid() then
                radius = (inst:GetPosition() - spawner:GetPosition()):Length()
            end

            if radius > TUNING.STARILIAD_BOSS_SPYDER_CHARGE_MIN_RADIUS
                and radius < TUNING.STARILIAD_BOSS_SPYDER_CHARGE_MAX_RADIUS then
                local is_inverse = true
                inst.sg.statemem.success_charge = true

                local dir = GetChargeDirection(inst, spawner, is_inverse)

                inst:ForceFacePoint(inst:GetPosition() + dir)
                inst.sg:GoToState("charge", {
                    radius = radius,
                    max_angle = 720,
                    is_inverse = is_inverse,
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
            end
        end,
    },

    State {
        name = "charge",
        tags = { "attack", "busy" },

        onenter = function(inst, data)
            inst.AnimState:PushAnimation("walk_loop", true)

            inst.sg.statemem.radius = data.radius
            inst.sg.statemem.max_angle = data.max_angle
            inst.sg.statemem.is_inverse = data.is_inverse

            inst.sg.statemem.cur_angle = 0
            inst.sg.statemem.last_pos = inst:GetPosition()

            inst.sg.statemem.fx = inst:SpawnChild("stariliad_boss_spyder_speed_burst_particle")
        end,

        onupdate = function(inst)
            local spawner = inst.components.entitytracker:GetEntity("spawner")
            if not (spawner and spawner:IsValid()) then
                inst.sg:GoToState("idle", "walk_pst")
                return
            end

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
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
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
