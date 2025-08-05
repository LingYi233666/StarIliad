local StarIliadHexaManager = Class(function(self, inst)
    self.inst = inst

    self.ball_prefab = "stariliad_hexa_ball"
    self.num_balls = 6
    self.radius = 10
    self.rotate_speed = 15 -- degrees

    self.balls = {}
    self.destinations = {}
    self.ignited = {}
    self.anchor_angle = 0

    inst:ListenForEvent("onremove", function()
        self:ClearBalls()
    end)
    inst:ListenForEvent("death", function()
        self:ClearBalls()
    end)
end)

function StarIliadHexaManager:SetRadius(radius)
    self.radius = radius
end

function StarIliadHexaManager:SpawnBalls(hide_balls)
    self:ClearBalls()

    local angle_step = 360 / self.num_balls
    for i = 1, self.num_balls do
        local angle = (self.anchor_angle + angle_step * (i - 1)) * DEGREES
        local offset = Vector3(math.cos(angle) * self.radius, 0, math.sin(angle) * self.radius)
        local destination = self.inst:GetPosition() + offset

        local ball = SpawnAt(self.ball_prefab, destination)
        if hide_balls then
            ball:Hide()
        end

        table.insert(self.balls, ball)
        table.insert(self.destinations, destination)
        table.insert(self.ignited, false)
    end
end

function StarIliadHexaManager:IgniteBall(index)
    if index < 1 or index > self.num_balls or self.ignited[index] then
        return
    end

    local ball = self.balls[index]

    self.ignited[index] = true

    -- Push this event, let ball to handle fire FX etc.
    ball:PushEvent("stariliad_hexa_ignite", { owner = self.inst, index = index })
end

function StarIliadHexaManager:ExtinguishBall(index)
    if index < 1 or index > self.num_balls or not self.ignited[index] then
        return
    end

    local ball = self.balls[index]

    self.ignited[index] = false

    -- Push this event, let ball to handle fire FX etc.
    ball:PushEvent("stariliad_hexa_extinguish", { owner = self.inst, index = index })
end

-- period = 0.167 ?
function StarIliadHexaManager:FirstIgniteAllBalls(period)
    if period == nil then
        for i = 1, self.num_balls do
            self:IgniteBall(i)
        end
        return
    end

    return self.inst:StartThread(function()
        for i = 1, self.num_balls do
            self:IgniteBall(i)
            Sleep(period)
        end
    end)
end

function StarIliadHexaManager:ExtinguishAllBalls(index)
    for i = 1, self.num_balls do
        self:ExtinguishBall(i)
    end
end

function StarIliadHexaManager:ClearBalls()
    for _, v in pairs(self.balls) do
        if v.KillFX then
            v:KillFX()
        else
            v:Remove()
        end
    end

    self.balls = {}
    self.destinations = {}
    self.anchor_angle = 0
end

function StarIliadHexaManager:StartRotating()
    self.inst:StartUpdatingComponent(self)
end

function StarIliadHexaManager:StopRotating()
    self.inst:StopUpdatingComponent(self)
    for _, v in pairs(self.balls) do
        v.Physics:Stop()
    end
end

function StarIliadHexaManager:BallsMoveToDest(dist_thres1, dist_thres2, min_speed, max_speed, instant)
    if instant then
        for i = 1, self.num_balls do
            self.balls[i]:SetPosition(self.destinations[i]:Get())
        end
        return
    end

    for i = 1, self.num_balls do
        local offset = self.destinations[i] - self.balls[i]:GetPosition()
        local distance = offset:Length()
        local direction = offset / distance
        local speed = nil

        if distance < dist_thres1 then
            self.balls[i].Physics:Stop()
            self.balls[i].Transform:SetPosition(self.destinations[i]:Get())
        elseif distance > dist_thres2 then
            speed = max_speed
        else
            speed = Remap(distance, dist_thres1, dist_thres2, min_speed, max_speed)
        end

        if speed then
            StarIliadBasic.SetVelByMotor(self.balls[i], (direction * speed):Get())
        end
    end
end

function StarIliadHexaManager:OnUpdate(dt)
    self.anchor_angle = self.anchor_angle + dt * self.rotate_speed
    if self.anchor_angle >= 360 then
        self.anchor_angle = self.anchor_angle - 360
    end

    local angle_step = 360 / self.num_balls
    for i = 1, self.num_balls do
        local angle = (self.anchor_angle + angle_step * (i - 1)) * DEGREES
        local offset = Vector3(math.cos(angle) * self.radius, 0, math.sin(angle) * self.radius)

        self.destinations[i] = self.inst:GetPosition() + offset
    end

    self:BallsMoveToDest(0.1, 5, 1, 10)
end

return StarIliadHexaManager
