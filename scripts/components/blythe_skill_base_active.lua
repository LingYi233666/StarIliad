local DefaultCostDefines = {
    hunger = {
        CanCost = function(player, x, y, z, target, value)
            return player.components.hunger and player.components.hunger.current >= value
        end,

        ApplyCost = function(player, x, y, z, target, value)
            player.components.hunger:DoDelta(-value, true)
        end,
    },

    sanity = {
        CanCost = function(player, x, y, z, target, value)
            return player.components.sanity and player.components.sanity.current >= value
        end,

        ApplyCost = function(player, x, y, z, target, value)
            player.components.sanity:DoDelta(-value, true)
        end,
    },

    health = {
        CanCost = function(player, x, y, z, target, value)
            return player.components.health and player.components.health.currenthealth >= value
        end,

        ApplyCost = function(player, x, y, z, target, value)
            player.components.health:DoDelta(-value, true, nil, nil, nil, true)
        end,
    },
}

local BlytheSkillBase_Active = Class(function(self, inst)
    self.inst = inst

    self.costs = {
        -- hunger = 0,
        -- sanity = 0,
        -- health = 0,

        -- your_fancy_cost = {
        --     CanCost = function(player, x, y, z, target)

        --     end,

        --     ApplyCost = function(player, x, y, z, target)

        --     end,
        -- },
    }

    self.cooldown = 0
    self.last_cast_time = 0

    self.can_cast_while_dead = false
    self.can_cast_while_busy = false
    self.can_cast_while_frozen = false
    self.can_cast_while_no_interrupt = false
    self.can_cast_while_riding = false
    self.can_cast_while_wearing_armor = false
end)

function BlytheSkillBase_Active:_IsDead()
    return (self.inst.components.health and self.inst.components.health:IsDead())
        or self.inst:HasTag("playerghost")
        or (self.inst.sg and self.inst.sg:HasStateTag("dead"))
end

function BlytheSkillBase_Active:_IsBusy()
    return self.inst:HasTag("busy")
        or (self.inst.sg and self.inst.sg:HasStateTag("busy"))
end

function BlytheSkillBase_Active:_IsFrozen()
    return self.inst.sg and (self.inst.sg:HasStateTag("frozen") or self.inst.sg:HasStateTag("thawing"))
end

function BlytheSkillBase_Active:_IsNoInterrupt()
    return self.inst:HasTag("nointerrupt")
        or (self.inst.sg and self.inst.sg:HasStateTag("nointerrupt"))
end

function BlytheSkillBase_Active:_IsRiding()
    return self.inst.components.rider and self.inst.components.rider:IsRiding()
end

function BlytheSkillBase_Active:_CanCost(x, y, z, target)
    for name, v in pairs(self.costs) do
        local result, reason = false, "UNKNOWN"
        if DefaultCostDefines[name] and type(v) == "number" then
            if DefaultCostDefines[name].CanCost then
                result = DefaultCostDefines[name].CanCost(self.inst, x, y, z, target, v)
            else
                result = true
            end

            if not result then
                reason = "NOT_ENOUGH_COST_" .. name:upper()
            end
        elseif type(v) == "table" then
            if v.CanCost then
                result = v.CanCost(self.inst, x, y, z, target)
            else
                result = true
            end

            if not result then
                reason = "NOT_ENOUGH_COST_" .. name:upper()
            end
        end

        if not result then
            return result, reason
        end
    end

    return true
end

function BlytheSkillBase_Active:_ApplyCost(x, y, z, target)
    for name, v in pairs(self.costs) do
        if DefaultCostDefines[name] and type(v) == "number" then
            DefaultCostDefines[name].ApplyCost(self.inst, x, y, z, target, v)
        elseif type(v) == "table" and v.ApplyCost then
            v.ApplyCost(self.inst, x, y, z, target)
        end
    end
end

function BlytheSkillBase_Active:GetTimeSinceLastCast()
    return GetTime() - self.last_cast_time
end

function BlytheSkillBase_Active:GetCooldownRemain()
    return math.max(0, self.cooldown - GetTime() + self.last_cast_time)
end

function BlytheSkillBase_Active:IsCoolingDown()
    return GetTime() - self.last_cast_time < self.cooldown
end

function BlytheSkillBase_Active:CanCast(x, y, z, target)
    if not self.can_cast_while_dead and self:_IsDead() then
        return false, "PLAYER_DEAD"
    end

    if not self.can_cast_while_busy and self:_IsBusy() then
        return false, "PLAYER_BUSY"
    end

    if not self.can_cast_while_frozen and self:_IsFrozen() then
        return false, "PLAYER_FROZEN"
    end

    if not self.can_cast_while_no_interrupt and self:_IsNoInterrupt() then
        return false, "PLAYER_NO_INTERRUPT"
    end

    if not self.can_cast_while_riding and self:_IsRiding() then
        return false, "PLAYER_RIDING"
    end

    if not self.can_cast_while_wearing_armor and StarIliadBasic.IsWearingArmor(self.inst) then
        return false, "PLAYER_WEARING_ARMOR"
    end

    if self:IsCoolingDown() then
        return false, "COOLING_DOWN"
    end

    if #self.costs > 0 then
        local cost_success, reason = self:_CanCost(x, y, z, target)
        if not cost_success then
            return false, reason
        end
    end

    return true
end

function BlytheSkillBase_Active:Cast(x, y, z, target)
    self:_ApplyCost(x, y, z, target)
    self.last_cast_time = GetTime()
end

function BlytheSkillBase_Active:OnSave()
    local data = {}
    if self:IsCoolingDown() then
        data.cooldown_remain = self:GetCooldownRemain()
        print("Cool down remain:", data.cooldown_remain)
    end

    return data
end

function BlytheSkillBase_Active:OnLoad(data)
    if data ~= nil then
        if data.cooldown_remain ~= nil then
            self.last_cast_time = data.cooldown_remain - self.cooldown
            print("Cool down remain:", self:GetCooldownRemain())
        end
    end
end

return BlytheSkillBase_Active
