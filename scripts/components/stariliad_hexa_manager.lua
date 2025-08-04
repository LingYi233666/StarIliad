local StarIliadHexaManager = Class(function(self, inst)
    self.inst = inst

    self.ball_prefab = ""
    self.num_balls = 6
    self.radius = 10
    self.rotate_speed = 15 -- degrees

    self.balls = {}
    self.destinations = {}
    self.anchor_angle = 0
end)

function StarIliadHexaManager:SpawnBalls()
    self:ClearBalls()

    local angle_step = 360 / self.num_balls
    for i = 1, self.num_balls do
        local angle = (self.anchor_angle + angle_step * (i - 1)) * DEGREES
        local offset = Vector3(math.cos(angle) * self.radius, 0, math.sin(angle) * self.radius)
        local destination = self.inst:GetPosition() + offset

        local ball = SpawnAt(self.ball_prefab, destination)

        table.insert(self.balls, ball)
        table.insert(self.destinations, destination)
    end

    self.inst:StartUpdatingComponent(self)
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
end

return StarIliadHexaManager
