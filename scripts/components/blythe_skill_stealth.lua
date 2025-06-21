local BlytheSkillBase_Active = require "components/blythe_skill_base_active"


local BlytheSkillStealth = Class(BlytheSkillBase_Active, function(self, inst)
    BlytheSkillBase_Active._ctor(self, inst)

    self.cooldown = 0.1
    self.costs.hunger = 5

    self.hunger_burn_rate = 3
    self.hunger_delta_bad_sg = -3
    self.speed_mult = 0.8
    self._on_state_change = function()
        if self.inst.sg:HasStateTag("blythe_dodge") then
            self:Stop()
            return
        end

        if self:IsStealth() then
            if self.inst.sg:HasStateTag("attack")
                or self.inst.sg:HasStateTag("aoe")
                or self.inst.sg:HasStateTag("busy")
                or self.inst.sg:HasStateTag("working") then
                self.inst.components.hunger:DoDelta(self.hunger_delta_bad_sg, true)
                self:TempEnableStealth(false)
            else
                self:TempEnableStealth(true)
            end
        end
    end

    self.is_stealth = false
end)

function BlytheSkillStealth:CanCast(x, y, z, target)
    local can_cost, reason = BlytheSkillBase_Active.CanCast(self, x, y, z, target)
    if not can_cost then
        return can_cost, reason
    end

    return true
end

function BlytheSkillStealth:Cast(x, y, z, target)
    BlytheSkillBase_Active.Cast(self, x, y, z, target)

    if self:IsStealth() then
        self:Stop()
    else
        self:Start()
    end
end

function BlytheSkillStealth:IsStealth()
    return self.is_stealth
end

function BlytheSkillStealth:Start()
    -- transfercombattarget

    self.is_stealth = true
    self.inst.components.blythe_stealth_handler:AddModifier(self.inst, "blythe_skill_stealth")
    self.inst.components.hunger.burnratemodifiers:SetModifier(self.inst, self.hunger_burn_rate, "blythe_skill_stealth")
    self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "blythe_skill_stealth", self.speed_mult)

    -- Force every attacker drop target
    self.inst:PushEvent("transfercombattarget")

    self.inst:ListenForEvent("newstate", self._on_state_change)

    self.inst:StartUpdatingComponent(self)

    self.inst.replica.blythe_skill_stealth:SetIsVisible(self.is_stealth)
end

function BlytheSkillStealth:Stop()
    self.is_stealth = false
    self.inst.components.blythe_stealth_handler:RemoveModifier(self.inst, "blythe_skill_stealth")
    self.inst.components.hunger.burnratemodifiers:RemoveModifier(self.inst, "blythe_skill_stealth")
    self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "blythe_skill_stealth")

    self.inst:RemoveEventCallback("newstate", self._on_state_change)

    self.inst:StopUpdatingComponent(self)

    self.inst.replica.blythe_skill_stealth:SetIsVisible(self.is_stealth)
end

function BlytheSkillStealth:TempEnableStealth(enable)
    if not self:IsStealth() then
        print("You should NOT use TempEnableStealth() while not stealth !")
        return
    end

    if enable then
        self.inst:PushEvent("transfercombattarget")

        self.inst.components.blythe_stealth_handler:AddModifier(self.inst, "blythe_skill_stealth")
    else
        self.inst.components.blythe_stealth_handler:RemoveModifier(self.inst, "blythe_skill_stealth")
    end

    self.inst.replica.blythe_skill_stealth:SetIsVisible(enable)
end

function BlytheSkillStealth:OnUpdate(dt)
    if not (self.inst.components.hunger and self.inst.components.hunger.current > 0) then
        self:Stop()
        return
    end
end

return BlytheSkillStealth
