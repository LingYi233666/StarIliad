local BlytheSkillBase_Active = require "components/blythe_skill_base_active"


local BlytheSkillHeal = Class(BlytheSkillBase_Active, function(self, inst)
    BlytheSkillBase_Active._ctor(self, inst)

    self.cooldown = 3
    self.costs.hunger = 15
    self.can_cast_while_riding = true

    self.radius = 25
    self.heal_percent_caster = 1.0
    self.heal_percent_ally = 0.75

    -- self.fxcolour = { 248 / 255, 248 / 255, 198 / 255 }
    self.fxcolour = { 255 / 255, 155 / 255, 205 / 255 }
    self.castsound = "dontstarve/pig/mini_game/cointoss"
end)

function BlytheSkillHeal:CanCast(x, y, z, target)
    local can_cost, reason = BlytheSkillBase_Active.CanCast(self, x, y, z, target)
    if not can_cost then
        return can_cost, reason
    end

    return true
end

function BlytheSkillHeal:Cast(x, y, z, target)
    BlytheSkillBase_Active.Cast(self, x, y, z, target)

    self.inst.sg:GoToState("blythe_heal")
end

function BlytheSkillHeal:DoHealing()
    local heal_value = self.inst.components.health.maxhealth

    self.inst.components.health:DoDelta(heal_value * self.heal_percent_caster, nil, self.inst.prefab)

    -- local beefalo = self.inst.components.rider and self.inst.components.rider:GetMount()
    -- if beefalo and beefalo:IsValid() and not IsEntityDead(beefalo, true) then
    --     beefalo.components.health:DoDelta(heal_value * self.heal_percent_ally, nil, self.inst.prefab)
    -- end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "_health" }, { "INLIMBO", "FX" })
    local beefalo = self.inst.components.rider and self.inst.components.rider:GetMount()

    if beefalo then
        table.insert(ents, beefalo)
    end

    for _, v in pairs(ents) do
        if v ~= self.inst
            and v:IsValid()
            and self.inst.components.combat
            and self.inst.components.combat:IsAlly(v)
            and v.components.health
            and not IsEntityDeadOrGhost(v, true) then
            v.components.health:DoDelta(heal_value * self.heal_percent_ally, nil, self.inst.prefab)
        end
    end
end

return BlytheSkillHeal
