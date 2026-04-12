local StarIliadWeatherIceMeteor = Class(function(self, inst)
    self.inst = inst


    -- Config
    -- self.range_countdown = { 240, 1530 }
    self.range_countdown = { 300, 1000 }
    self.range_eruption_duration = { 30, 90 }
    self.range_ash_hover_duration = { 150, 270 }
    -- self.range_time_first_warning = { 120, 480 }
    -- self.range_time_second_warning = { 60, 240 }
    -- self.range_time_third_warning = { 30, 120 }
    self.range_time_between_meteor = { 0.5, 1 }
    self.max_radius_meteor = 12
    self.percent_time_first_warning = 0.5
    self.percent_time_second_warning = 0.25
    self.percent_time_third_warning = 0.125


    -- Data
    self.erupting = false
    self.init_peace_countdown = nil
    self.peace_countdown = nil

    self.erupting_countdown = nil
    self.period_meteor_task = nil
end)

function StarIliadWeatherIceMeteor:DoDeltaPeace(t)
    local t1 = self.init_peace_countdown * self.percent_time_first_warning
    local t2 = self.init_peace_countdown * self.percent_time_second_warning
    local t3 = self.init_peace_countdown * self.percent_time_third_warning

    local old_countdown = self.peace_countdown

    self.peace_countdown = self.peace_countdown + t

    if old_countdown > t1 and self.peace_countdown <= t1 then
        -- TODO: Send first warn
    elseif old_countdown > t2 and self.peace_countdown <= t2 then
        -- TODO: Send second warn
    elseif old_countdown > t3 and self.peace_countdown <= t3 then
        -- TODO: Send third warn
    end

    if self.peace_countdown <= 0 then
        local duration = GetRandomMinMax(unpack(self.range_eruption_duration))
        self:StartErupt(duration)
    end
end

function StarIliadWeatherIceMeteor:DoDeltaErupt(t)
    local old_countdown = self.erupting_countdown

    self.erupting_countdown = self.erupting_countdown + t

    if self.erupting_countdown <= 0 then
        self:StopErupt()
    end
end

local function MeteorTaskFn(self)
    if self.period_meteor_task then
        self.period_meteor_task:Cancel()
    end
    self.period_meteor_task = self.inst:DoTaskInTime(
        GetRandomMinMax(unpack(self.range_time_between_meteor)),
        function()
            self:SpawnMeteors()
        end
    )
end

function StarIliadWeatherIceMeteor:StartErupt(duration)
    self.inst:StopUpdatingComponent(self)

    self.erupting_countdown = duration
    self.erupting = true

    -- TODO: Periodic spawn meteors among players
    MeteorTaskFn(self)

    self.inst:StartUpdatingComponent(self)
end

function StarIliadWeatherIceMeteor:StopErupt()
    self:Cancel()

    -- self.erupting = false

    -- TODO: Send ash HUD hover

    -- TODO: Restart a erupt after N seconds
end

function StarIliadWeatherIceMeteor:Cancel()
    self.inst:StopUpdatingComponent(self)

    if self.period_meteor_task then
        self.period_meteor_task:Cancel()
    end

    self.erupting = false
    self.init_peace_countdown = nil
    self.peace_countdown = nil

    self.erupting_countdown = nil
    self.period_meteor_task = nil
end

function StarIliadWeatherIceMeteor:SpawnMeteors()
    local players_pos = {}
    for _, v in pairs(AllPlayers) do
        table.insert(players_pos, v:GetPosition())
    end

    local clusters = StarIliadMath.DBSCAN(players_pos, 20, 1)

    for id, cluster in pairs(clusters) do
        local center = Vector3(0, 0, 0)
        for _, v in pairs(cluster) do
            center = center + v
        end
        center = center / #cluster

        local offset = Vector3FromTheta(math.random() * TWOPI, math.random() * self.max_radius_meteor)

        SpawnAt("stariliad_ice_meteor", center, nil, offset)
    end
end

function StarIliadWeatherIceMeteor:OnUpdate(dt)
    if self.erupting then
        self:DoDeltaErupt(-dt)
    else
        self:DoDeltaPeace(-dt)
    end
end

function StarIliadWeatherIceMeteor:GetDebugString()

end

return StarIliadWeatherIceMeteor
