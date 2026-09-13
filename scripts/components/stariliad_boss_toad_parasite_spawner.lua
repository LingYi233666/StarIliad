local StariliadBossToadParasiteSpawner = Class(function(self, inst)
    self.inst             = inst

    self.countdown        = nil
    self.try_spawn_period = nil
    self.toad             = nil

    self._unlink_toad_fn  = function()
        self:UnlinkToad()
    end

    inst:WatchWorldState("season", function(inst, season)
        self:OnSeasonChange(season)
    end)

    inst:DoTaskInTime(1, function()
        self:OnSeasonChange()
    end)
end)

function StariliadBossToadParasiteSpawner:OnSeasonChange()
    local season = TheWorld.state.season
    if season ~= "spring" then
        self:StopCountdown()
        return
    end

    if self.toad then
        self:StopCountdown()
        return
    end

    if self.countdown then
        return
    end

    self:StartCountdown(TheWorld.state.springlength * TUNING.TOTAL_DAY_TIME * GetRandomMinMax(0.5, 0.7))
end

function StariliadBossToadParasiteSpawner:StartCountdown(countdown)
    if self.countdown ~= nil then
        return
    end

    print("[StariliadBossToadParasiteSpawner] Start countdown: ", countdown)

    self.countdown = countdown
    self.inst:StartUpdatingComponent(self)
end

function StariliadBossToadParasiteSpawner:StopCountdown()
    print("[StariliadBossToadParasiteSpawner] Stop countdown, old countdown:", self.countdown)

    self.inst:StopUpdatingComponent(self)
    self.countdown = nil
    self.try_spawn_period = nil
end

function StariliadBossToadParasiteSpawner:LinkToad(toad)
    if self.toad ~= nil then
        print("[StariliadBossToadParasiteSpawner] Toad is already linked, unlinking old toad...")
        self:UnlinkToad()
    end

    self.toad = toad
    self.inst:ListenForEvent("death", self._unlink_toad_fn, toad)
    self.inst:ListenForEvent("onremove", self._unlink_toad_fn, toad)
end

function StariliadBossToadParasiteSpawner:UnlinkToad()
    if self.toad == nil then
        print("[StariliadBossToadParasiteSpawner] Toad is nil, returning...")
        return
    end

    self.inst:RemoveEventCallback("death", self._unlink_toad_fn, self.toad)
    self.inst:RemoveEventCallback("onremove", self._unlink_toad_fn, self.toad)

    self.toad = nil
end

local function OffsetCheck(final_pos)
    local x, y, z = final_pos:Get()
    local structures = TheSim:FindEntities(x, y, z, 12, { "structure" }, { "INLIMBO" })

    if #structures > 0 then
        return false
    end

    return true
end

function StariliadBossToadParasiteSpawner:FindVictimAndPos()
    local candidates = {}

    for _, v in pairs(AllPlayers) do
        if not IsEntityDeadOrGhost(v, true) then
            local pos = v:GetPosition()
            local offset = FindWalkableOffset(pos, math.random() * TWOPI, math.random(6, 12), 10, nil, false,
                OffsetCheck, false, false)
            if offset then
                table.insert(candidates, { v, pos + offset })
            end
        end
    end

    if #candidates > 0 then
        return unpack(GetRandomItem(candidates))
    end
end

function StariliadBossToadParasiteSpawner:OnSave()
    local data = {}
    local references = {}

    if self.countdown ~= nil then
        data.countdown = self.countdown
    end

    if self.toad ~= nil and self.toad:IsValid() then
        data.toad = self.toad.GUID
        table.insert(references, self.toad.GUID)
    end

    return data, references
end

function StariliadBossToadParasiteSpawner:OnLoad(data)
    if data ~= nil then
        if data.countdown ~= nil then
            self:StartCountdown(data.countdown)
        end
    end
end

function StariliadBossToadParasiteSpawner:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        if savedata.toad ~= nil then
            local new_ent = newents[savedata.toad]
            if new_ent then
                self:LinkToad(new_ent.entity)
            end
        end
    end
end

function StariliadBossToadParasiteSpawner:OnUpdate(dt)
    if self.countdown == nil then
        print("[StariliadBossToadParasiteSpawner] Countdown is nil, returning...")
        return
    end

    self.countdown = math.max(-1, self.countdown - dt)
    if self.countdown <= 0 then
        if self.try_spawn_period then
            self.try_spawn_period = self.try_spawn_period - dt
        end

        if self.try_spawn_period == nil or self.try_spawn_period <= 0 then
            local victim, pos = self:FindVictimAndPos()
            if victim and pos then
                print("[StariliadBossToadParasiteSpawner] Spawn toad for victim: ", victim, " at pos: ", pos)

                local toad = SpawnAt("stariliad_boss_toad_parasite", pos)
                self:LinkToad(toad)

                toad.components.combat:SetTarget(victim)
                toad.sg:GoToState("spawn")


                self:StopCountdown()
            else
                self.try_spawn_period = GetRandomMinMax(10, 15)
            end
        end
    end
end

StariliadBossToadParasiteSpawner.LongUpdate = StariliadBossToadParasiteSpawner.OnUpdate

function StariliadBossToadParasiteSpawner:GetDebugString()
    -- local fmt = "Count down: %d, Try spawn period: %d, Toad: %s"
    -- return string.format(fmt, self.countdown, self.try_spawn_period, tostring(self.toad))

    local count_down_str = type(self.countdown) == "number" and string.format("%d", self.countdown) or
        tostring(self.countdown)
    local try_spawn_period_str = type(self.try_spawn_period) == "number" and string.format("%d", self.try_spawn_period) or
        tostring(self.try_spawn_period)

    return string.format("Count down: %s, Try spawn period: %s, Toad: %s", count_down_str, try_spawn_period_str,
        tostring(self.toad))
end

-- print(TheWorld.components.stariliad_boss_toad_parasite_spawner:GetDebugString())
-- TheWorld.components.stariliad_boss_toad_parasite_spawner.countdown = 5

return StariliadBossToadParasiteSpawner
