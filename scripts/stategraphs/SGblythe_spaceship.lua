require("stategraphs/commonstates")

local actionhandlers =
{

}

local events =
{
    -- EventHandler("fly_back", function(inst, data)
    --     inst.sg:GoToState("flyback")
    -- end),
}

local function AdjustCameraToAlignVector(x, z)
    -- 计算输入向量在水平面上的角度
    -- Lua的math.atan2(y, x)函数返回弧度，我们需要将其转换为度数
    -- 注意：atan2(y, x)的参数顺序是y在前，x在后
    local target_angle_rad = math.atan2(z, x)
    local target_angle_deg = math.deg(target_angle_rad)

    -- 重要的是要处理角度的周期性 (0-360度)
    local desired_screen_right_angle_deg = target_angle_deg
    local new_heading_target = desired_screen_right_angle_deg - 90

    -- 确保角度在0到360度之间
    new_heading_target = math.fmod(new_heading_target, 360)
    if new_heading_target < 0 then
        new_heading_target = new_heading_target + 360
    end

    TheCamera:SetHeadingTarget(new_heading_target)
    -- TheCamera:SetPitchTarget(TheCamera.pitch_target or 45) -- 可选：保持或设置一个默认的俯仰角度，避免视角突然变化
    TheCamera:Snap()

    -- print(string.format("AdjustCameraToAlignVector: Camera heading set to %.2f degrees.", new_heading_target))
end

local function SetAnimDirection(inst, velocity)
    local x, y, z = velocity:Get()
    local v1 = math.sqrt(x * x + z * z)
    local angle = math.atan2(y, v1) * RADIANS

    -- if angle < -90 or angle > 90 then
    --     print(string.format("wrong angle: %.3f", angle))
    --     return
    -- end

    print(string.format("Cur angle: %.3f", angle))

    local offset = 1e-3
    local percent = Remap(angle, -90, 90, offset, 1 - offset)

    inst.AnimState:SetPercent("idle_debug", percent)
end

local function TeleportPlayer(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    ThePlayer.Transform:SetPosition(x, y, z)
end

local states =
{
    State {
        name = "cutscene1",
        onenter = function(inst, data)
            inst:Show()
            inst.Physics:Stop()

            local start_pos = data.start_pos
            local end_pos = data.end_pos
            local duration = data.duration
            local delta_pos = end_pos - start_pos

            inst.sg.statemem.start_pos = start_pos
            inst.sg.statemem.end_pos = end_pos
            inst.sg.statemem.delta_pos = delta_pos
            inst.sg.statemem.duration = duration

            ---------------------------------------------
            ThePlayer:Hide()
            ThePlayer.Physics:SetCollisionMask(COLLISION.GROUND)

            TheCamera.mindist = 9
            TheCamera.maxdist = 10
            TheCamera.maxdistpitch = 89

            inst.Transform:SetPosition(start_pos:Get())


            TeleportPlayer(inst)
            AdjustCameraToAlignVector(delta_pos.x, delta_pos.z)

            TheCamera.distancetarget = TheCamera.maxdist
            TheCamera:Snap()

            inst.sg:SetTimeout(duration)
        end,

        onupdate = function(inst)
            TeleportPlayer(inst)

            local delta_pos = inst.sg.statemem.delta_pos
            local duration = inst.sg.statemem.duration

            local velocity = delta_pos / duration
            -- inst.Physics:SetVel(velocity.x, velocity.y, velocity.z)

            inst:ForceFacePoint(inst:GetPosition() + delta_pos)
            local v1 = math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
            inst.Physics:SetMotorVel(v1, velocity.y, 0)

            SetAnimDirection(inst, velocity)

            print(inst:GetPosition())
        end,

        ontimeout = function(inst)
            ThePlayer:Show()
            inst.Physics:Stop()
            SetAnimDirection(inst, Vector3(0, 0, 0))

            inst.sg:GoToState("idle")
        end,


        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)

            end),
        },

        events =
        {
            -- EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State {
        name = "idle",
        onenter = function(inst)
            -- inst:Hide()
            inst.Physics:Stop()
        end,
    },
}


return StateGraph("SGblythe_spaceship", states, events, "idle", actionhandlers)
