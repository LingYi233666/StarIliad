local StarIliadWeatherIceMeteor = Class(function(self, inst)
    self.inst = inst

    -- Config
    -- self.range_peace_duration = { 240, 1530 }
    self.range_peace_duration = { 600, 1200 }
    self.range_eruption_duration = { 15, 25 }
    self.range_ash_hover_duration = { 150, 270 }
    -- self.range_time_first_warning = { 120, 480 }
    -- self.range_time_second_warning = { 60, 240 }
    -- self.range_time_third_warning = { 30, 120 }
    self.range_time_between_meteor = { 1, 2 }
    self.max_radius_meteor = 12
    self.percent_time_first_warning = 0.5
    self.percent_time_second_warning = 0.25
    self.percent_time_third_warning = 0.125

    -- Data
    self.init_peace_countdown = nil
    self.peace_countdown = nil

    self.init_erupting_countdown = nil
    self.erupting_countdown = nil

    self.period_meteor_task = nil
    self.period_music_task = nil

    self.icecano = nil


    -- Watch iswinter to trigger
    local function CheckFn()
        if TheWorld.state.iswinter then
            if self.init_peace_countdown == nil and self.init_erupting_countdown == nil then
                print("Start ice meteor because enter winter!")
                self:StartPeace(self:CalcPeaceDuration())
            end
        else
            if self.init_peace_countdown ~= nil then
                -- Only cancel if peace countdown
                self:Cancel()
            elseif self.init_erupting_countdown ~= nil then
                -- If erupting, do nothing, let it stop by itself
            end
        end
    end

    inst:WatchWorldState("iswinter", CheckFn)

    -- Init
    inst:DoTaskInTime(1, CheckFn)
end)

function StarIliadWeatherIceMeteor:TrySpawnIcecano()
    if self.icecano and self.icecano:IsValid() then
        return
    end
end

---------------------------------- Peace ----------------------------------

function StarIliadWeatherIceMeteor:StartPeace(init_duration, cur_duration)
    self:Cancel()

    self.init_peace_countdown = init_duration
    self.peace_countdown = cur_duration or init_duration

    self.inst:StartUpdatingComponent(self)

    print(string.format("Start ice meteor, peace time: %d/%d", self.peace_countdown, self.init_peace_countdown))
end

function StarIliadWeatherIceMeteor:DoDeltaPeace(t)
    local t1 = self.init_peace_countdown * self.percent_time_first_warning
    local t2 = self.init_peace_countdown * self.percent_time_second_warning
    local t3 = self.init_peace_countdown * self.percent_time_third_warning

    local old_countdown = self.peace_countdown

    self.peace_countdown = self.peace_countdown + t

    local warning_prefab = nil
    if old_countdown > t1 and self.peace_countdown <= t1 then
        -- First warn
        warning_prefab = "stariliad_ice_meteor_erupt_warning_lv1"
    elseif old_countdown > t2 and self.peace_countdown <= t2 then
        -- Second warn
        warning_prefab = "stariliad_ice_meteor_erupt_warning_lv2"
    elseif old_countdown > t3 and self.peace_countdown <= t3 then
        -- Third warn
        warning_prefab = "stariliad_ice_meteor_erupt_warning_lv3"
    end

    if warning_prefab then
        print("Send ice meteor erupt warning:", warning_prefab)
        for _, v in pairs(AllPlayers) do
            SpawnPrefab(warning_prefab):SetTarget(v)
            v:DoTaskInTime(GetRandomMinMax(1, 2), function()
                if v.components.talker then
                    v.components.talker:Say(GetString(v, "ANNOUNCE_QUAKE"))
                end
            end)
        end

        TheWorld:PushEvent("stariliad_ice_meteor_erupt_warning", { prefab = warning_prefab })
    end

    if self.peace_countdown <= 0 then
        local duration = GetRandomMinMax(unpack(self.range_eruption_duration))
        self:StartErupt(duration)
    end
end

---------------------------------- Erupt ----------------------------------

local function MeteorTaskFn(self)
    if self.period_meteor_task then
        self.period_meteor_task:Cancel()
    end
    self.period_meteor_task = self.inst:DoTaskInTime(
        GetRandomMinMax(unpack(self.range_time_between_meteor)),
        function()
            self:SpawnMeteors()
            MeteorTaskFn(self)
        end
    )
end

function StarIliadWeatherIceMeteor:StartErupt(init_duration, cur_duration)
    self:Cancel()

    self.init_erupting_countdown = init_duration
    self.erupting_countdown = cur_duration or init_duration

    -- Periodic spawn meteors among players
    MeteorTaskFn(self)

    -- Play triggered music
    self.period_music_task = self.inst:DoPeriodicTask(0.33, function()
        for _, v in pairs(AllPlayers) do
            SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["triggeredevent"], v.userid,
                "stariliad_weather_ice_meteor", 1, 1)
        end
    end)

    self.inst:StartUpdatingComponent(self)


    for _, v in pairs(AllPlayers) do
        v:DoTaskInTime(GetRandomMinMax(0, 0.5), function()
            if v.components.talker then
                v.components.talker:Say(GetString(v, "ANNOUNCE_STARILIAD_ICE_METEOR_ERUPT_WARNING"))
            end
        end)
    end

    ShakeAllCameras(CAMERASHAKE.FULL, 4.0, 0.02, 2.0)

    TheWorld:PushEvent("stariliad_start_erupting_ice_meteor")

    print(string.format("Erupt ice meteor time: %d/%d", self.erupting_countdown, self.init_erupting_countdown))
end

function StarIliadWeatherIceMeteor:DoDeltaErupt(t)
    local old_countdown = self.erupting_countdown

    self.erupting_countdown = self.erupting_countdown + t

    if self.erupting_countdown <= 0 then
        self:StopErupt()

        if TheWorld.state.iswinter then
            print("Try restart ice meteor peace countdown")
            -- Restart a erupt after N seconds
            self:StartPeace(self:CalcPeaceDuration())
        end
    end
end

function StarIliadWeatherIceMeteor:StopErupt()
    self:Cancel()

    -- TODO: Send ash HUD hover

    print("Ice meteor erupt stop!")
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

        self.inst:DoTaskInTime(math.random() * 0.33, function()
            SpawnAt("stariliad_ice_meteor", center, nil, offset):StartMeteor()
        end)
    end

    -- ShakeAllCameras(CAMERASHAKE.FULL, 1.0, 0.02, 2.0)
end

---------------------------------- Common ----------------------------------

function StarIliadWeatherIceMeteor:CalcPeaceDuration()
    -- return self.range_peace_duration[1] +
    --     math.sin(TheWorld.state.seasonprogress * PI) * (self.range_peace_duration[2] - self.range_peace_duration[1])

    return self.range_peace_duration[1] +
        (math.sin(TheWorld.state.seasonprogress * PI + PI) + 1) *
        (self.range_peace_duration[2] - self.range_peace_duration[1])


    -- return Remap(TheWorld.state.seasonprogress, 0, 1, self.range_peace_duration[2], self.range_peace_duration[1])
end

function StarIliadWeatherIceMeteor:IsErupting()
    return self.init_erupting_countdown ~= nil
end

function StarIliadWeatherIceMeteor:Cancel()
    local is_erupting = self.init_erupting_countdown ~= nil

    self.inst:StopUpdatingComponent(self)

    if self.period_meteor_task then
        self.period_meteor_task:Cancel()
    end
    self.period_meteor_task = nil

    if self.period_music_task then
        self.period_music_task:Cancel()
    end
    self.period_music_task = nil

    self.init_peace_countdown = nil
    self.peace_countdown = nil

    self.init_erupting_countdown = nil
    self.erupting_countdown = nil

    if is_erupting then
        TheWorld:PushEvent("stariliad_stop_erupting_ice_meteor")
    end
end

function StarIliadWeatherIceMeteor:OnUpdate(dt)
    if self.init_erupting_countdown ~= nil then
        self:DoDeltaErupt(-dt)
    else
        self:DoDeltaPeace(-dt)
    end
end

function StarIliadWeatherIceMeteor:OnSave()
    local data = {}

    if self.init_erupting_countdown ~= nil then
        data.init_erupting_countdown = self.init_erupting_countdown
        data.erupting_countdown = self.erupting_countdown
    elseif self.init_peace_countdown ~= nil then
        data.init_peace_countdown = self.init_peace_countdown
        data.peace_countdown = self.peace_countdown
    else

    end

    return data
end

function StarIliadWeatherIceMeteor:OnLoad(data)
    if data ~= nil then
        if data.init_erupting_countdown ~= nil then
            self:StartErupt(data.init_erupting_countdown, data.erupting_countdown)
        elseif data.init_peace_countdown ~= nil then
            self:StartPeace(data.init_peace_countdown, data.peace_countdown)
        end
    end
end

function StarIliadWeatherIceMeteor:GetDebugString()
    if self.init_erupting_countdown ~= nil then
        return string.format("Erupting: %d/%d", self.erupting_countdown, self.init_erupting_countdown)
    elseif self.init_peace_countdown ~= nil then
        return string.format("Peace: %d/%d", self.peace_countdown, self.init_peace_countdown)
    else
        return "Not active"
    end
end

return StarIliadWeatherIceMeteor
