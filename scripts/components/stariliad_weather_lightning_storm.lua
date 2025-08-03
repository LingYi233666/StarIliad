local STATE = {
    NONE = "NONE",
    RUNNING = "RUNNING",
}

local StarIliadWeatherLightningStorm = Class(function(self, inst)
    self.inst = inst

    -- Config
    self.weather_minmax_duration = { 250, 350 }
    self.lightning_strike_minmax_period = { 8, 14 }
    self.lightning_strike_minmax_speed = { 1, 3 }
    self.rain_time_percent = { 0.2, 0.3 }
    -- self.rain_time_percent = { 0.05, 0.1 }
    self.check_minmax_cd = { TUNING.TOTAL_DAY_TIME * 0.4, TUNING.TOTAL_DAY_TIME * 0.6 }
    self.start_possibility_init = 0.2
    self.start_possibility_bonus = 0.1
    self.rain_fx_minmax_bonus = { 1, 2048 }

    -- State
    self.state = STATE.NONE

    -- Check data
    self.check_countdown = GetRandomMinMax(unpack(self.check_minmax_cd))
    self.start_possibility = self.start_possibility_init

    -- Running data
    self.weather_duration = nil -- remain constant in one weather event
    self.weather_time_elapse = nil
    self.lightning_strike_countdown = nil
    -- self.rain_countdown = nil
    self.start_rain_time = nil
    self.warn_rain_time = nil

    self.inst:StartUpdatingComponent(self)
end)

function StarIliadWeatherLightningStorm:GenerateRunningData()
    self.weather_duration = GetRandomMinMax(unpack(self.weather_minmax_duration))
    self.weather_time_elapse = 0
    self.lightning_strike_countdown = GetRandomMinMax(unpack(self.lightning_strike_minmax_period))
    -- self.rain_countdown = self.weather_duration * GetRandomMinMax(unpack(self.rain_time_percent))
    self.start_rain_time = self.weather_duration * GetRandomMinMax(unpack(self.rain_time_percent))
    self.warn_rain_time = self.start_rain_time - 7.5
end

function StarIliadWeatherLightningStorm:GetLightningStrikeSpeed()
    local percent = self.weather_time_elapse / self.weather_duration
    return self.lightning_strike_minmax_speed[1] +
        math.sin(percent * PI) * (self.lightning_strike_minmax_speed[2] - self.lightning_strike_minmax_speed[1])
end

function StarIliadWeatherLightningStorm:GetRainFXBonus()
    if self.state ~= STATE.RUNNING
        or not TheWorld.state.israining
        or not self.start_rain_time
        or self.weather_time_elapse < self.start_rain_time then
        return 0
    end



    -- local percent = self.weather_time_elapse / self.weather_duration
    -- return self.rain_fx_minmax_bonus[1] +
    --     math.sin(percent * PI) * (self.rain_fx_minmax_bonus[2] - self.rain_fx_minmax_bonus[1])

    local rain_percent = (self.weather_time_elapse - self.start_rain_time) /
        (self.weather_duration - self.start_rain_time)
    -- return self.rain_fx_minmax_bonus[1] +
    --     math.sin(rain_percent * PI) * (self.rain_fx_minmax_bonus[2] - self.rain_fx_minmax_bonus[1])

    -- return Remap(rain_percent, 0, 1, self.rain_fx_minmax_bonus[2], self.rain_fx_minmax_bonus[1])

    return self.rain_fx_minmax_bonus[1] +
        math.cos(rain_percent * PI * 0.5) * (self.rain_fx_minmax_bonus[2] - self.rain_fx_minmax_bonus[1])
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

    -- print("Lightning strike on", luck_guy, ", offset:", offset, ", radius:", offset:Length())
    TheWorld:PushEvent("ms_sendlightningstrike", luck_guy:GetPosition() + offset)
end

function StarIliadWeatherLightningStorm:GetLightningCandidate()
    local percent = self.weather_time_elapse / self.weather_duration
    local factor = math.sin(percent * PI)

    local candidates = {
        lightning = Remap(factor, 0, 1, 0.1, 0.4),
        thunder_close = Remap(factor, 0, 1, 0.1, 0.2),
        thunder_far = Remap(factor, 0, 1, 0.8, 0.4),
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

function StarIliadWeatherLightningStorm:WarnRain()
    print("Use raindrop fx to warn heavy rain !")
    -- TheWorld:PushEvent("ms_forceprecipitation", true)
    for _, v in pairs(AllPlayers) do
        v:SpawnChild("stariliad_raindrop_warning")
    end
end

function StarIliadWeatherLightningStorm:OnUpdate(dt)
    if self.state == STATE.NONE then
        if not TheWorld.state.issummer then
            return
        end

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

        return
    end

    if self.state ~= STATE.RUNNING then
        print("Un-except state:", self.state)
        return
    end

    local old_weather_time_elapse = self.weather_time_elapse
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

    -- if self.rain_countdown then
    --     self.rain_countdown = self.rain_countdown - dt
    --     if self.rain_countdown <= 0 then
    --         self:ReleaseRain()

    --         self.rain_countdown = nil
    --     end
    -- else
    --     -- Keep raining
    --     -- TheWorld:PushEvent("ms_deltamoisture", 10)
    -- end

    local lightning_start_rain_time = self.start_rain_time + 0.5
    if old_weather_time_elapse < lightning_start_rain_time and self.weather_time_elapse >= lightning_start_rain_time then
        -- self:DoLightningStrike()
        SpawnPrefab("thunder_close")
    end

    if self.weather_time_elapse >= self.start_rain_time then
        if old_weather_time_elapse < self.start_rain_time then
            self:ReleaseRain()
        end

        -- Keep raining
        TheWorld:PushEvent("ms_deltamoisture", 1)
    end

    if old_weather_time_elapse < self.warn_rain_time and self.weather_time_elapse >= self.warn_rain_time then
        self:WarnRain()
    end
end

function StarIliadWeatherLightningStorm:OnSave()
    return {
        state = self.state,

        -- Check data
        check_countdown = self.check_countdown,
        start_possibility = self.start_possibility,

        -- Running data
        weather_duration = self.weather_duration,
        weather_time_elapse = self.weather_time_elapse,
        lightning_strike_countdown = self.lightning_strike_countdown,
        -- rain_countdown = self.rain_countdown,
        start_rain_time = self.start_rain_time,
        warn_rain_time = self.warn_rain_time,
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
        if data.weather_duration ~= nil then
            self.weather_duration = data.weather_duration
        end
        if data.weather_time_elapse ~= nil then
            self.weather_time_elapse = data.weather_time_elapse
        end
        if data.lightning_strike_countdown ~= nil then
            self.lightning_strike_countdown = data.lightning_strike_countdown
        end
        -- if data.rain_countdown ~= nil then
        --     self.rain_countdown = data.rain_countdown
        -- end
        if data.start_rain_time ~= nil then
            self.start_rain_time = data.start_rain_time
        end
        if data.warn_rain_time ~= nil then
            self.warn_rain_time = data.warn_rain_time
        end
    end
end

-- si_lightning_storm()
-- print(TheWorld.components.stariliad_weather_lightning_storm:GetDebugString())
function StarIliadWeatherLightningStorm:GetDebugString()
    local str = string.format("State: %s", tostring(self.state))

    if self.state == STATE.NONE then
        str = str ..
            string.format(", next check: %d, possibility: %d%%", self.check_countdown, self.start_possibility * 100)
    elseif self.state == STATE.RUNNING then
        str = str ..
            string.format(", progress: %d/%d, next lightning(with speed mult): %d",
                self.weather_time_elapse, self.weather_duration,
                self.lightning_strike_countdown / self:GetLightningStrikeSpeed())

        -- if self.rain_countdown then
        --     str = str .. string.format(", rain: %d", self.rain_countdown)
        -- end

        str = str .. string.format(", start rain at: %d", self.start_rain_time)
    end

    return str
end

StarIliadWeatherLightningStorm.OnLongUpdate = StarIliadWeatherLightningStorm.OnUpdate

return StarIliadWeatherLightningStorm
