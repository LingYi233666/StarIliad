local BlytheSkillBase_Active = require "components/blythe_skill_base_active"


local BlytheSkillScan = Class(BlytheSkillBase_Active, function(self, inst)
    BlytheSkillBase_Active._ctor(self, inst)

    self.cooldown = 15
    self.costs.hunger = 15

    self.duration = 13.1
    self.reveal_step = 10
    self.reveal_radius = 76
    self.reveal_stealth_radius = 36
    self.reveal_cooldown = 3.5


    self.fxs = {}
    self.start_scan_time = nil
    self.last_reveal_time = nil
end)

function BlytheSkillScan:CanCast(x, y, z, target)
    local can_cost, reason = BlytheSkillBase_Active.CanCast(self, x, y, z, target)
    if not can_cost then
        return can_cost, reason
    end

    return true
end

function BlytheSkillScan:Cast(x, y, z, target)
    BlytheSkillBase_Active.Cast(self, x, y, z, target)

    self:Start(1.8)
end

function BlytheSkillScan:GetDuration()
    if self.start_scan_time == nil then
        return
    end

    return GetTime() - self.start_scan_time
end

local function RelocatePos(pos, grid_size)
    local new_pos = pos
    new_pos.x = math.floor(pos.x / grid_size + 0.5) * grid_size
    new_pos.y = 0
    new_pos.z = math.floor(pos.z / grid_size + 0.5) * grid_size
    return new_pos
end

function BlytheSkillScan:SpawnMarks()
    local mid_pos = RelocatePos(self.inst:GetPosition(), 1)

    local fx = SpawnAt("blythe_scan_mark_center", mid_pos)
    fx._master:set(self.inst)
    table.insert(self.fxs, fx)

    self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/scan")
end

function BlytheSkillScan:ClearFX()
    for _, v in pairs(self.fxs) do
        if v and v:IsValid() then
            if v.FadeOut then
                v:FadeOut()
            else
                v:Remove()
            end
        end
    end
    self.fxs = {}
end

function BlytheSkillScan:RevealMaps()
    if self.inst.player_classified == nil then
        return
    end

    local mid_pos = self.inst:GetPosition()

    if self.offset_storage == nil then
        self.offset_storage = {}

        local x_count = 2 * self.reveal_radius / self.reveal_step
        local z_count = 2 * self.reveal_radius / self.reveal_step

        for i = 0, x_count do
            for j = 0, z_count do
                local x = -self.reveal_radius + i * self.reveal_step
                local z = -self.reveal_radius + j * self.reveal_step
                local offset = Vector3(x, 0, z)
                local dist = offset:Length()
                if dist <= self.reveal_radius then
                    table.insert(self.offset_storage, offset)
                end
            end
        end
    end

    for _, offset in pairs(self.offset_storage) do
        self.inst.player_classified.MapExplorer:RevealArea(
            mid_pos.x + offset.x,
            0,
            mid_pos.z + offset.z
        )
    end
end

function BlytheSkillScan:RevealStealthTargets()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, self.reveal_stealth_radius, { "stealth" }, { "NOBLOCK", "FX" },
        { "monster", "hostile" })
    for _, v in pairs(ents) do
        if v ~= self.inst and not self.inst.components.combat:IsAlly(v) and not IsEntityDead(v, true) then
            local dist = math.sqrt(self.inst:GetDistanceSqToInst(v))
            local delay = Remap(dist, 0, self.reveal_stealth_radius, 0, 1)

            self.inst:DoTaskInTime(delay, function()
                if v:HasTag("stealth") then
                    v:PushEvent("attacked", { attacker = self.inst, damage = 0 })
                end
            end)
        end
    end
end

function BlytheSkillScan:PulseForImportant(delay, duration)
    if self.pulse_start_task then
        self.pulse_start_task:Cancel()
        self.pulse_start_task = nil
    end

    if delay then
        self.pulse_start_task = self.inst:DoTaskInTime(delay, function()
            self:PulseForImportant(nil, duration)
        end)
    else
        self.inst:AddTag("blythe_skill_scan_pulse")
        self.pulse_stop_task = self.inst:DoTaskInTime(duration, function()
            self.inst:RemoveTag("blythe_skill_scan_pulse")
            self.pulse_stop_task = nil
        end)
    end
end

-- ThePlayer.components.blythe_skill_scan:Start(1.8)
function BlytheSkillScan:Start(delay)
    if self.delay_start_task then
        self.delay_start_task:Cancel()
        self.delay_start_task = nil
    end

    if delay and delay >= 0 then
        self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/scan_pre")
        self.delay_start_task = self.inst:DoTaskInTime(delay, function()
            self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/scan_ready")

            self:Start()
        end)
    else
        self.start_scan_time = GetTime()
        self:SpawnMarks()
        self:RevealMaps()
        self:RevealStealthTargets()
        self:PulseForImportant(1, 2)
        self.last_reveal_time = GetTime()
        self.inst:StartUpdatingComponent(self)
    end
end

function BlytheSkillScan:Stop()
    self.inst:StopUpdatingComponent(self)

    self:ClearFX()
    self.start_scan_time = nil
    self.last_reveal_time = nil
end

function BlytheSkillScan:OnUpdate(dt)
    if self:GetDuration() >= self.duration then
        self:Stop()
        return
    end

    if GetTime() - self.last_reveal_time >= self.reveal_cooldown then
        self:SpawnMarks()
        self:RevealMaps()
        self:RevealStealthTargets()
        self:PulseForImportant(1, 2)
        self.last_reveal_time = GetTime()
    end
end

return BlytheSkillScan
