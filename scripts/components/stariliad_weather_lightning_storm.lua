local STATE = {
    NONE = "NONE",
    RUNNING = "RUNNING",
}

local StarIliadWeatherLightningStorm = Class(function(self, inst)
    self.inst = inst

    -- Config
    self.weather_minmax_duration = { 200, 300 }
    self.lightning_strike_minmax_period = { 8, 14 }
    self.lightning_strike_minmax_speed = { 1, 3 }
    self.rain_time_percent = { 0.2, 0.3 }
    -- self.rain_time_percent = { 0.05, 0.1 }
    self.check_minmax_cd = { TUNING.TOTAL_DAY_TIME * 0.4, TUNING.TOTAL_DAY_TIME * 0.6 }
    self.start_possibility_init = 0.4
    self.start_possibility_bonus = 0.1
    self.rain_fx_minmax_bonus = { 50, 512 }

    -- State
    self.state = STATE.NONE

    -- Check data
    self.check_countdown = GetRandomMinMax(unpack(self.check_minmax_cd))
    self.start_possibility = self.start_possibility_init
    -- self.spawned_flag = false

    -- Running data
    self.weather_duration = nil -- remain constant in one weather event
    self.weather_time_elapse = nil
    self.lightning_strike_countdown = nil
    self.rain_countdown = nil

    self.inst:StartUpdatingComponent(self)

    -- local function OnIsSummer()
    --     if TheWorld.state.issummer then

    --     else
    --         self.spawned_flag = false
    --     end
    -- end

    -- inst:WatchWorldState("issummer", OnIsSummer)
    -- inst:DoTaskInTime(FRAMES, OnIsSummer)
end)

function StarIliadWeatherLightningStorm:GenerateRunningData()
    self.weather_duration = GetRandomMinMax(unpack(self.weather_minmax_duration))
    self.weather_time_elapse = 0
    self.lightning_strike_countdown = GetRandomMinMax(unpack(self.lightning_strike_minmax_period))
    self.rain_countdown = self.weather_duration * GetRandomMinMax(unpack(self.rain_time_percent))
end

function StarIliadWeatherLightningStorm:GetLightningStrikeSpeed()
    local percent = self.weather_time_elapse / self.weather_duration
    return self.lightning_strike_minmax_speed[1] +
        math.sin(percent * PI) * (self.lightning_strike_minmax_speed[2] - self.lightning_strike_minmax_speed[1])
end

function StarIliadWeatherLightningStorm:GetRainFXBonus()
    if self.state ~= STATE.RUNNING or not TheWorld.state.israining then
        return 0
    end

    local percent = self.weather_time_elapse / self.weather_duration
    return self.rain_fx_minmax_bonus[1] +
        math.sin(percent * PI) * (self.rain_fx_minmax_bonus[2] - self.rain_fx_minmax_bonus[1])
end

function StarIliadWeatherLightningStorm:DoLightningStrike()
    local candidates = {}
    for _, v in pairs(AllPlayers) do
        if not IsEntityDeadOrGhost(v, true) then
            table.insert(candidates, v)
        end
    end

    if #candidates == 0 then
        candidates = AllPlayers
    end

    if #candidates == 0 then
        print("No candidate, lightning strike failed !")
        return
    end

    local luck_guy = GetRandomItem(candidates)
    local offset = Vector3FromTheta(math.random() * PI2, GetRandomMinMax(0, 20))

    print("Lightning strike on", luck_guy, ", offset:", offset, ", radius:", offset:Length())
    TheWorld:PushEvent("ms_sendlightningstrike", luck_guy:GetPosition() + offset)
end

function StarIliadWeatherLightningStorm:GetLightningCandidate()
    local percent = self.weather_time_elapse / self.weather_duration
    local factor = math.sin(percent * PI)

    local candidates = {
        lightning = Remap(factor, 0, 1, 0.2, 0.4),
        thunder_close = Remap(factor, 0, 1, 0.2, 0.1),
        thunder_far = Remap(factor, 0, 1, 0.6, 0.5),
    }

    local selection = weighted_random_choice(candidates)

    return selection
end

-- function StarIliadWeatherLightningStorm:SpawnThunderSound()
--     local percent = self.weather_time_elapse / self.weather_duration
--     local factor = math.sin(percent * PI)
--     SpawnPrefab(factor * math.random() > .3 and "thunder_close" or "thunder_far")
-- end

function StarIliadWeatherLightningStorm:StartWeather()
    if self.state == STATE.RUNNING then
        print("Lightning storm already running, no need to start again.")
        return
    end

    self:GenerateRunningData()

    self.state = STATE.RUNNING

    print("Start lightning storm !")
end

function StarIliadWeatherLightningStorm:StopWeather()
    self.state = STATE.NONE

    print("Stop lightning storm, the rain maybe continue because this component can't control rain !")
end

function StarIliadWeatherLightningStorm:ReleaseRain()
    print("Release heavy rain")
    TheWorld:PushEvent("ms_forceprecipitation", true)
end

function StarIliadWeatherLightningStorm:OnUpdate(dt)
    if self.state == STATE.NONE then
        if not TheWorld.state.issummer then
            return
        end

        -- if self.spawned_flag then
        --     return
        -- end

        -- First 5 days or last 3 days in summer will not spawn lightning storm
        if TheWorld.state.elapseddaysinseason < 5 or TheWorld.state.remainingdaysinseason < 3 then
            return
        end

        -- Check periodically
        self.check_countdown = self.check_countdown - dt
        if self.check_countdown > 0 then
            return
        end
        self.check_countdown = GetRandomMinMax(unpack(self.check_minmax_cd))

        if math.random() > self.start_possibility then
            self.start_possibility = math.min(1, self.start_possibility + self.start_possibility_bonus)

            print("Lightning storm start possibility failed, increase possibility to", self.start_possibility)
            return
        end
        self.start_possibility = self.start_possibility_init

        self:StartWeather()


        local season_remain_time = (1 - TheWorld.state.seasonprogress) * TheWorld.state.summerlength *
            TUNING.TOTAL_DAY_TIME
        print("Season remain time:", season_remain_time)

        -- Make sure don't start lightning storm again this summer
        self.check_countdown = season_remain_time + GetRandomMinMax(unpack(self.check_minmax_cd))

        -- Make sure don't start lightning storm again this summer
        -- self.spawned_flag = true

        return
    end

    if self.state ~= STATE.RUNNING then
        print("Un-except state:", self.state)
        return
    end

    self.weather_time_elapse = self.weather_time_elapse + dt
    if self.weather_time_elapse >= self.weather_duration then
        self:StopWeather()
        return
    end

    self.lightning_strike_countdown = self.lightning_strike_countdown - dt * self:GetLightningStrikeSpeed()
    if self.lightning_strike_countdown <= 0 then
        local selection = self:GetLightningCandidate()
        if selection == "lightning" then
            self:DoLightningStrike()
        elseif selection == "thunder_close" or selection == "thunder_far" then
            SpawnPrefab(selection)
        end

        self.lightning_strike_countdown = GetRandomMinMax(unpack(self.lightning_strike_minmax_period))
    end

    if self.rain_countdown then
        self.rain_countdown = self.rain_countdown - dt
        if self.rain_countdown <= 0 then
            self:ReleaseRain()

            self.rain_countdown = nil
        end
    else
        -- Keep raining
        TheWorld:PushEvent("ms_deltamoisture", 10)
    end
end

function StarIliadWeatherLightningStorm:OnSave()
    return {
        state = self.state,

        -- Check data
        check_countdown = self.check_countdown,
        start_possibility = self.start_possibility,
        -- spawned_flag = self.spawned_flag,

        -- Running data
        weather_duration = self.weather_duration,
        weather_time_elapse = self.weather_time_elapse,
        lightning_strike_countdown = self.lightning_strike_countdown,
        rain_countdown = self.rain_countdown,
    }
end

function StarIliadWeatherLightningStorm:OnLoad(data)
    if data ~= nil then
        if data.state ~= nil then
            self.state = data.state
        end
        if data.check_countdown ~= nil then
            self.check_countdown = data.check_countdown
        end
        if data.start_possibility ~= nil then
            self.start_possibility = data.start_possibility
        end
        -- if data.spawned_flag ~= nil then
        --     self.spawned_flag = data.spawned_flag
        -- end
        if data.weather_duration ~= nil then
            self.weather_duration = data.weather_duration
        end
        if data.weather_time_elapse ~= nil then
            self.weather_time_elapse = data.weather_time_elapse
        end
        if data.lightning_strike_countdown ~= nil then
            self.lightning_strike_countdown = data.lightning_strike_countdown
        end
        if data.rain_countdown ~= nil then
            self.rain_countdown = data.rain_countdown
        end
    end
end

-- print(TheWorld.components.stariliad_weather_lightning_storm:GetDebugString())
function StarIliadWeatherLightningStorm:GetDebugString()
    -- local str = string.format("State: %s, spawned flag: %s", tostring(self.state), tostring(self.spawned_flag))
    local str = string.format("State: %s", tostring(self.state))

    if self.state == STATE.NONE then
        str = str ..
            string.format(", next check: %d, possibility: %d%%", self.check_countdown, self.start_possibility * 100)
    elseif self.state == STATE.RUNNING then
        str = str ..
            string.format(", progress: %d/%d, next lightning(with speed mult): %d",
                self.weather_time_elapse, self.weather_duration,
                self.lightning_strike_countdown / self:GetLightningStrikeSpeed())

        if self.rain_countdown then
            str = str .. string.format(", rain: %d", self.rain_countdown)
        end
    end

    return str
end

StarIliadWeatherLightningStorm.OnLongUpdate = StarIliadWeatherLightningStorm.OnUpdate

return StarIliadWeatherLightningStorm
