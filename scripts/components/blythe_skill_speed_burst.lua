local BlytheSkillBase_Passive = require("components/blythe_skill_base_passive")

local BlytheSkillSpeedBurst = Class(BlytheSkillBase_Passive, function(self, inst)
    BlytheSkillBase_Passive._ctor(self, inst)


    self.required_charge_time = 3
    self.speed_mult = 3
    self.hunger_burn_rate = 5
    self.hunger_collide_cost = 2
    self.collide_damage = 200
    self.work_damage = 30

    self.recently_collide = {}

    self.last_velocity = nil
    self.last_pos = nil
    -- self.last_rotate_time = nil
    self.static_duration = 0
    self.in_speed_burst = false
    self.charge_time = 0
end)

function BlytheSkillSpeedBurst:SetInSpeedBurst(val)
    self.in_speed_burst = val
    self.inst.replica.blythe_skill_speed_burst:SetInSpeedBurst(val)
end

function BlytheSkillSpeedBurst:IsInSpeedBurst()
    return self.in_speed_burst
end

function BlytheSkillSpeedBurst:DoDeltaChargeTime(delta)
    self.charge_time = math.clamp(self.charge_time + delta, 0, self.required_charge_time)

    if not self.in_speed_burst and self.charge_time >= self.required_charge_time then
        self:StartSpeedBurst()
    elseif self.in_speed_burst and self.charge_time < self.required_charge_time then
        self:StopSpeedBurst()
    end
end

function BlytheSkillSpeedBurst:ResetChargeTime()
    self:DoDeltaChargeTime(-self.required_charge_time)
end

function BlytheSkillSpeedBurst:Enable(enable, is_onload)
    local old_enable = self.enable
    BlytheSkillBase_Passive.Enable(self, enable, is_onload)

    if not old_enable and enable then
        self:ResetChargeTime()
        self.inst:StartUpdatingComponent(self)
    elseif old_enable and not enable then
        self:ResetChargeTime()
        self.inst:StopUpdatingComponent(self)
    end
end

local shinny_colors = {
    { 1, 1, 0, 1 },
    { 1, 0, 0, 1 },
    { 1, 0, 1, 1 },
    { 1, 0, 0, 1 },
}

local function ShinnyTask(inst, self)
    -- if self.shinny_flag then
    --     inst.AnimState:SetAddColour(1, 1, 0, 1)
    -- else
    --     inst.AnimState:SetAddColour(1, 0, 1, 1)
    -- end

    inst.AnimState:SetAddColour(unpack(shinny_colors[self.shinny_flag]))

    self.shinny_flag = self.shinny_flag + 1
    if self.shinny_flag > #shinny_colors then
        self.shinny_flag = 1
    end
end

local function CollideTask(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 6, nil, { "INLIMBO", "FX" })
    for _, v in pairs(ents) do
        if v:IsValid() then
            local dist = math.sqrt(inst:GetDistanceSqToInst(v))
            if dist < inst:GetPhysicsRadius(0) + v:GetPhysicsRadius(0) + 0.3 and self:CanCollide(v) then
                self:OnPhysicsCollision(v)
            end
        end
    end
end

function BlytheSkillSpeedBurst:StartSpeedBurst()
    self:SetInSpeedBurst(true)

    self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "blythe_skill_speed_burst", self.speed_mult)
    self.inst.components.locomotor:SetTriggersCreep(false)

    self.inst.components.hunger.burnratemodifiers:SetModifier(self.inst, self.hunger_burn_rate,
        "blythe_skill_speed_burst")

    if not self.shinny_task then
        self.shinny_flag = 1
        self.shinny_task = self.inst:DoPeriodicTask(0.1, ShinnyTask, nil, self)
    end

    -- if not self.collide_task then
    --     self.collide_task = self.inst:DoPeriodicTask(0, CollideTask, nil, self)
    -- end

    if not self.particle_fx then
        self.particle_fx = self.inst:SpawnChild("blythe_speed_burst_particle")
    end

    self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/speed_burst", "blythe_skill_speed_burst")
end

function BlytheSkillSpeedBurst:StopSpeedBurst()
    self:SetInSpeedBurst(false)

    self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "blythe_skill_speed_burst")
    self.inst.components.locomotor:SetTriggersCreep(true)

    self.inst.components.hunger.burnratemodifiers:RemoveModifier(self.inst, "blythe_skill_speed_burst")

    if self.shinny_task then
        self.shinny_task:Cancel()
        self.shinny_task = nil
    end
    self.inst.AnimState:SetAddColour(0, 0, 0, 0)

    if self.collide_task then
        self.collide_task:Cancel()
        self.collide_task = nil
    end

    if self.particle_fx and self.particle_fx:IsValid() then
        self.particle_fx:Remove()
    end
    self.particle_fx = nil

    self.inst.SoundEmitter:KillSound("blythe_skill_speed_burst")

    self.last_velocity = nil
    self.last_pos = nil
end

function BlytheSkillSpeedBurst:CanCollide(other)
    if not other or other.prefab == "world" then
        return false
    end

    if self.recently_collide[other] then
        return false
    end

    if other == self.inst then
        return false
    end

    return self.inst.components.combat:CanTarget(other)
        or
        (other.components.workable ~= nil and other.components.workable:CanBeWorked() and other.components.workable.action ~= ACTIONS.NET)
end

function BlytheSkillSpeedBurst:OnPhysicsCollision(other)
    self.recently_collide[other] = self.inst:DoTaskInTime(1, function()
        self.recently_collide[other] = nil
    end)


    local success_hit = false

    if other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then
        SpawnAt("collapse_small", other)
        other.components.workable:WorkedBy(self.inst, self.work_damage)

        success_hit = true
        -- print("Do work to", other)
    elseif other.components.combat and self.inst.components.combat:CanTarget(other) then
        local spdamage = {
            stariliad_spdamage_beam = self.collide_damage,
        }
        other.components.combat:GetAttacked(self.inst, 0, nil, nil, spdamage)
        success_hit = true

        -- print("Do damage to", other)
    end

    if success_hit then
        ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, self.inst, 40)

        self.last_collide_time = GetTime()

        self.inst.components.hunger:DoDelta(-self.hunger_collide_cost, true)

        self.inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
    end
end

function BlytheSkillSpeedBurst:OnUpdate(dt)
    local velocity = Vector3(self.inst.Physics:GetVelocity())
    local pos = self.inst:GetPosition()

    if self:IsInSpeedBurst() then
        CollideTask(self.inst, self)
    end

    -- if not self.inst.sg:HasStateTag("moving")
    --     or self.inst:HasTag("playerghost")
    --     or self.inst.components.hunger:IsStarving()
    --     or velocity:Length() < 5.5 then
    --     if self.in_speed_burst then
    --         print("stop 1", self.inst.sg:HasStateTag("moving"), velocity:Length())
    --     end
    --     self:ResetChargeTime()

    if not self.inst.sg:HasStateTag("moving")
        or velocity:Length() < 5.5
        or (self.last_pos and (pos - self.last_pos):Length() < 5.5 * FRAMES) then
        -- if self.last_static_time and GetTime() - self.last_static_time > 0.3 then
        --     self:ResetChargeTime()
        -- else
        --     self.last_static_time = GetTime()
        -- end

        self.static_duration = self.static_duration + dt
    else
        self.static_duration = 0
    end

    if self.inst:HasTag("playerghost") or self.inst.components.hunger:IsStarving() or self.static_duration > 0.2 then
        -- if self.in_speed_burst then
        --     print("stop 1")
        -- end
        self:ResetChargeTime()
    elseif self.last_velocity
        and math.abs(StarIliadMath.AngleBetweenVectors(self.last_velocity, velocity, true)) > 90
        and (self.last_collide_time == nil or GetTime() - self.last_collide_time > 0.1) then
        -- if self.last_rotate_time and GetTime() - self.last_rotate_time > 0.2 then
        --     if self.in_speed_burst then
        --         print("stop 2")
        --     end
        --     self:ResetChargeTime()
        -- else
        --     self.last_rotate_time = GetTime()
        -- end
        -- if self.in_speed_burst then
        --     print("stop 2")
        -- end
        self:ResetChargeTime()
    else
        self:DoDeltaChargeTime(dt)
    end



    self.last_velocity = velocity
    self.last_pos = pos
end

function BlytheSkillSpeedBurst:GetDebugString()
    return string.format("Charge time: %.2f/%.2f%s", self.charge_time, self.required_charge_time,
        self.enable and " (enabled)" or "")
end

return BlytheSkillSpeedBurst
