local StarIliadWeatherFallingStar = Class(function(self, inst)
    self.inst = inst

    -- Config
    self.season_rate = {
        spring = 0.25,
        summer = 1.5,
        autumn = 1,
        winter = 1.25,
    }
    self.phase_rate = {
        day = 0,
        dusk = 1,
        night = 0.5,
    }
    self.base_possibility = 0.001 -- for every frame


    -- Debug
    self.current_phase = TheWorld.state.phase
    self.spawn_counter = 0
    -- TheWorld.components.stariliad_weather_falling_star.base_possibility=0.1

    inst:WatchWorldState("phase", function()
        if self.spawn_counter > 0 then
            print(string.format("Spawn %d falling stars in day %d %s", self.spawn_counter, TheWorld.state.cycles,
                self.current_phase))
            self.current_phase = TheWorld.state.phase
            self.spawn_counter = 0
        end
    end)

    self.inst:StartUpdatingComponent(self)
end)

function StarIliadWeatherFallingStar:SpawnStar(target_pos)
    local min_dist = math.huge
    for _, v in pairs(AllPlayers) do
        min_dist = math.min(min_dist, (v:GetPosition() - target_pos):Length())
    end

    if min_dist < 60 then
        local start_pos = target_pos + Vector3FromTheta(math.random() * PI2, 6)
        start_pos.y = start_pos.y + GetRandomMinMax(35, 45)

        local star = SpawnPrefab("stariliad_falling_star")
        star:DoFalling(start_pos, target_pos)
    else
        SpawnAt("stariliad_falling_star", target_pos)
    end
end

function StarIliadWeatherFallingStar:GetSpawnPos()
    local candidates = {}
    local dist = 40
    for dx = -dist, dist, 5 do
        for dz = -dist, dist, 5 do
            for _, v in pairs(AllPlayers) do
                local pos = v:GetPosition()
                pos.x = pos.x + dx
                pos.z = pos.z + dz

                table.insert(candidates, pos)
            end
        end
    end

    if #candidates > 0 then
        return candidates[math.random(#candidates)] + Vector3(UnitRand() * 3, 0, UnitRand() * 3)
    end
end

function StarIliadWeatherFallingStar:OnUpdate(dt)
    local season_rate = self.season_rate[TheWorld.state.season] or 1
    local phase_rate = self.phase_rate[TheWorld.state.phase] or 1

    local possibility = self.base_possibility * season_rate * phase_rate

    if TheWorld.state.israining or TheWorld.state.issnowing or TheWorld.state.islunarhailing or TheWorld.state.isacidraining then
        possibility = 0
    end

    if math.random() < possibility then
        local target_pos = self:GetSpawnPos()
        if target_pos then
            self:SpawnStar(target_pos)

            -- Debug
            self.spawn_counter = self.spawn_counter + 1
            print("Cur spawn count:", self.spawn_counter)
        end
    end
end

return StarIliadWeatherFallingStar
