local StarIliadSpacePirateInvasion = Class(Class, function(self, inst)
    self.inst = inst

    -- 平均生存天数	下次袭击间隔（天）	袭击的猎犬数量	警告阶段的时间（秒）
    -- 0 ~ 8	    5 ~ 8	            1	                120
    -- 8 ~ 25	    5 ~ 10	            3 ~ 4           	60
    -- 25 ~ 50	    7 ~ 12	            4 ~ 6           	45
    -- 50 ~ 100 	9 ~ 14	            5 ~ 7           	30
    -- 100 以上	    11 ~ 16	            7 ~ 10          	30

    -- Config
    self.range_invasion_duration = {
        [{ 0, 8 }] = { 5, 8 },
        [{ 8, 25 }] = { 5, 10 },
        [{ 25, 50 }] = { 7, 12 },
        [{ 50, 100 }] = { 9, 14 },
        [{ 100, math.huge }] = { 11, 16 },
    }

    self.range_pirate_score = {
        [{ 0, 8 }] = { 1, 1 },
        [{ 8, 25 }] = { 3, 4 },
        [{ 25, 50 }] = { 4, 5 },
        [{ 50, 100 }] = { 5, 6 },
        [{ 100, math.huge }] = { 7, 8 },
    }

    self.warning_duration = {
        [{ 0, 8 }] = 120,
        [{ 8, 25 }] = 110,
        [{ 25, 50 }] = 100,
        [{ 50, 100 }] = 100,
        [{ 100, math.huge }] = 100,
    }

    self.pirate_lv2_score_cost = 3
    self.pirate_lv2_occur_percent = 0.5

    self.pirate_lv3_score_cost = 5
    self.pirate_lv3_occur_percent = 0.3

    -- Data
    self.invasion_countdown = nil
    self.warning_threshold = nil

    self.inst:DoTaskInTime(1, function()
        if #AllPlayers > 0 then
            self.inst:StartUpdatingComponent(self)
        end
    end)

    self.inst:ListenForEvent("playeractivated", function()
        self.inst:StartUpdatingComponent(self)
    end)

    self.inst:ListenForEvent("playerdeactivated", function()
        if #AllPlayers == 0 then
            self.inst:StopUpdatingComponent(self)
        end
    end)
end)

function StarIliadSpacePirateInvasion:FastForwardToWarning()
    self.invasion_countdown = self.warning_threshold + 0.1
end

function StarIliadSpacePirateInvasion:FastForwardToInvasion()
    self.invasion_countdown = 0
end

function StarIliadSpacePirateInvasion:GetMeanSurvivalDays()
    local sum = 0
    for i, v in ipairs(AllPlayers) do
        sum = sum + v.components.age:GetAge() / TUNING.TOTAL_DAY_TIME
    end
    return sum > 0 and sum / #AllPlayers or 0
end

function StarIliadSpacePirateInvasion:RollInvasionCountDown()
    local mean_survival_days = self:GetMeanSurvivalDays()
    if mean_survival_days > 0 then
        for day_range, countdown_range in pairs(self.range_invasion_duration) do
            if mean_survival_days >= day_range[1] and mean_survival_days <= day_range[2] then
                return GetRandomMinMax(unpack(countdown_range)) * TUNING.TOTAL_DAY_TIME
            end
        end
    end

    print("RollInvasionCountDown failed: mean_survival_days <= 0")
end

function StarIliadSpacePirateInvasion:RollWarningThreshold()
    local mean_survival_days = self:GetMeanSurvivalDays()
    if mean_survival_days <= 0 then
        print("RollWarningThreshold failed: mean_survival_days <= 0")
        return
    end

    for day_range, warning_duration in pairs(self.warning_duration) do
        if mean_survival_days >= day_range[1] and mean_survival_days <= day_range[2] then
            return warning_duration
        end
    end
end

function StarIliadSpacePirateInvasion:ReleaseWarning()
    local center_players = self:CollectCenterPlayers()

    for _, v in pairs(center_players) do
        print("Release warning for player:", v)

        local pos = v:GetPosition()
        local offset = FindWalkableOffset(pos, math.random() * TWOPI, math.random(25, 40), 8, nil, true, nil, true, true)
        if offset then
            local probe = SpawnAt("stariliad_space_pirate_probe", pos, nil, offset)
            probe:SetTarget(v)
        else
            print("Release warning for player", v, " failed to spawn probe with offset")
        end
    end
end

function StarIliadSpacePirateInvasion:RollPirateDefine()
    local mean_survival_days = self:GetMeanSurvivalDays()
    if mean_survival_days <= 0 then
        print("RollPirateDefine failed: mean_survival_days <= 0")
        return
    end

    local score = -1
    for day_range, v in pairs(self.range_pirate_score) do
        if mean_survival_days >= day_range[1] and mean_survival_days <= day_range[2] then
            score = math.random(unpack(v))
            break
        end
    end

    if score <= 0 then
        return
    end

    local defines = {}

    while score >= self.pirate_lv3_score_cost do
        if math.random() > self.pirate_lv3_occur_percent then
            break
        end

        if defines.stariliad_space_pirate_solider_lv3 == nil then
            defines.stariliad_space_pirate_solider_lv3 = 0
        end
        defines.stariliad_space_pirate_solider_lv3 = defines.stariliad_space_pirate_solider_lv3 + 1
        score = score - self.pirate_lv3_score_cost
    end

    while score >= self.pirate_lv2_score_cost do
        if math.random() > self.pirate_lv2_occur_percent then
            break
        end

        if defines.stariliad_space_pirate_solider_lv2 == nil then
            defines.stariliad_space_pirate_solider_lv2 = 0
        end
        defines.stariliad_space_pirate_solider_lv2 = defines.stariliad_space_pirate_solider_lv2 + 1
        score = score - self.pirate_lv2_score_cost
    end

    if score > 0 then
        defines.stariliad_space_pirate_solider_lv1 = score
    end

    return defines
end

function StarIliadSpacePirateInvasion:SpawnPiratesForPlayer(player, pirate_defines)
    -- local x, y, z = player.Transform:GetWorldPosition()
    local pos = player:GetPosition()

    for prefab, count in pairs(pirate_defines) do
        for i = 1, count do
            -- FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn, allow_water, allow_boats)
            local offset = FindWalkableOffset(pos, math.random() * TWOPI, math.random(25, 40), 8, nil, nil, nil, false,
                false)
            if offset then
                local pirate = SpawnAt(prefab, pos, nil, offset)
                if pirate.components.combat then
                    pirate.components.combat:SetTarget(player)
                end
            end
        end
    end
end

function StarIliadSpacePirateInvasion:OnSave()
    return {
        invasion_countdown = self.invasion_countdown,
        warning_threshold = self.warning_threshold,
    }
end

function StarIliadSpacePirateInvasion:OnLoad(data)
    if data ~= nil then
        if data.invasion_countdown ~= nil then
            self.invasion_countdown = data.invasion_countdown
        end
        if data.warning_threshold ~= nil then
            self.warning_threshold = data.warning_threshold
        end
    end
end

function StarIliadSpacePirateInvasion:CollectCenterPlayers()
    local center_players = {}

    local players = {}
    local players_pos = {}
    for _, v in pairs(AllPlayers) do
        if not IsEntityDeadOrGhost(v, true) then
            table.insert(players, v)
            table.insert(players_pos, v:GetPosition())
        end
    end

    local clusters = StarIliadMath.DBSCAN(players_pos, 20, 1, true)
    for _, cluster in pairs(clusters) do
        local center = Vector3(0, 0, 0)
        local players_in_cluster = {}
        for _, v in pairs(cluster) do
            center = center + players_pos[v]
            table.insert(players_in_cluster, players[v])
        end
        center = center / #cluster

        local closest_player = nil
        local closest_distance_sq = math.huge
        for k, player in pairs(players_in_cluster) do
            local distance_sq = center:DistSq(player:GetPosition())
            if distance_sq < closest_distance_sq then
                closest_distance_sq = distance_sq
                closest_player = player
            end
        end

        if closest_player then
            table.insert(center_players, closest_player)
        end
    end

    return center_players
end

function StarIliadSpacePirateInvasion:OnUpdate(dt)
    local mean_survival_days = self:GetMeanSurvivalDays()
    if mean_survival_days <= 0 then
        return
    end

    if self.invasion_countdown == nil or self.warning_threshold == nil then
        self.invasion_countdown = self:RollInvasionCountDown()
        self.warning_threshold = self:RollWarningThreshold()
        return
    end

    local old_countdown = self.invasion_countdown

    if self.invasion_countdown > 0 then
        self.invasion_countdown = self.invasion_countdown - dt
    end

    if old_countdown > self.warning_threshold and self.invasion_countdown <= self.warning_threshold then
        self:ReleaseWarning()
    end

    if self.invasion_countdown <= 0 then
        -- Spawn pirates
        -- for _, v in pairs(AllPlayers) do
        --     if not IsEntityDeadOrGhost(v, true) then
        --         local pirate_defines = self:RollPirateDefine()
        --         if pirate_defines ~= nil then
        --             print("Spawn pirate for", v)
        --             dumptable(pirate_defines)
        --             print("--------------------------------")
        --             self:SpawnPiratesForPlayer(v, pirate_defines)
        --         end
        --     end
        -- end

        local center_players = self:CollectCenterPlayers()
        for _, v in pairs(center_players) do
            local pirate_defines = self:RollPirateDefine()
            if pirate_defines ~= nil then
                print("Spawn pirate for", v)
                dumptable(pirate_defines)
                print("--------------------------------")
                self:SpawnPiratesForPlayer(v, pirate_defines)
            end
        end

        TheWorld:PushEvent("stariliad_space_pirate_invasion_start")

        self.invasion_countdown = self:RollInvasionCountDown()
    end
end

-- print(TheWorld.components.stariliad_space_pirate_invasion:GetDebugString())
-- TheWorld.components.stariliad_space_pirate_invasion:FastForwardToWarning()
-- TheWorld.components.stariliad_space_pirate_invasion:FastForwardToInvasion()
function StarIliadSpacePirateInvasion:GetDebugString()
    -- if self.invasion_countdown == nil then
    --     return "invasion_countdown: nil"
    -- end

    -- return string.format("invasion_countdown: %d", self.invasion_countdown)

    local invasion_countdown_str = type(self.invasion_countdown) == "number" and
        string.format("%d", self.invasion_countdown) or tostring(self.invasion_countdown)

    local warning_threshold_str = type(self.warning_threshold) == "number" and
        string.format("%d", self.warning_threshold) or tostring(self.warning_threshold)

    return string.format("invasion_countdown: %s, warning_threshold: %s", invasion_countdown_str, warning_threshold_str)
end

return StarIliadSpacePirateInvasion
