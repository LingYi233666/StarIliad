local BlytheStatusBonus = Class(function(self, inst)
    self.inst = inst

    self.base_value = {
        hunger = TUNING.BLYTHE_HUNGER,
        health = TUNING.BLYTHE_HEALTH,
        sanity = TUNING.BLYTHE_SANITY,
    }

    self.bonus_value = {
        hunger = 0,
        health = 0,
        sanity = 0,
    }

    self.use_blythe_reroll_data_handler = true
end)

function BlytheStatusBonus:AddBonus(dtype, val)
    self.bonus_value[dtype] = math.max(self.bonus_value[dtype] + val, 0)

    self:Apply()
end

function BlytheStatusBonus:Apply()
    local hunger_percent = self.inst.components.hunger:GetPercent()
    local health_percent = self.inst.components.health:GetPercent()
    local sanity_percent = self.inst.components.sanity:GetPercent()

    self.inst.components.hunger.max = self.base_value.hunger + self.bonus_value.hunger
    self.inst.components.health.maxhealth = self.base_value.health + self.bonus_value.health
    self.inst.components.sanity.max = self.base_value.sanity + self.bonus_value.sanity

    self.inst.components.hunger:SetPercent(hunger_percent)
    self.inst.components.health:SetPercent(health_percent)
    self.inst.components.sanity:SetPercent(sanity_percent)
end

function BlytheStatusBonus:OnSave()
    local data = {
        bonus_value = self.bonus_value,
        old_percent = {
            hunger = self.inst.components.hunger:GetPercent(),
            health = self.inst.components.health:GetPercent(),
            sanity = self.inst.components.sanity:GetPercent(),
        },
    }

    return data
end

function BlytheStatusBonus:OnLoad(data)
    if data ~= nil then
        if data.bonus_value ~= nil then
            self.bonus_value = data.bonus_value
        end
    end

    self:Apply()

    if data ~= nil then
        if data.old_percent ~= nil then
            if data.old_percent.hunger ~= nil then
                self.inst.components.hunger:SetPercent(data.old_percent.hunger)
            end
            if data.old_percent.health ~= nil then
                self.inst.components.health:SetPercent(data.old_percent.health)
            end
            if data.old_percent.sanity ~= nil then
                self.inst.components.sanity:SetPercent(data.old_percent.sanity)
            end
        end
    end
end

return BlytheStatusBonus
