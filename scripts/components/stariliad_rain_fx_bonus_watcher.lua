local function onbonus(self, val)
    self.inst.replica.stariliad_rain_fx_bonus_watcher:SetRainFXBonus(val)
end

local StarIliadRainFXBonusWatcher = Class(function(self, inst)
    self.inst = inst

    self.bonus = 0
    -- self.sound_intensity = 0
    self.update_countdown = 0

    self.inst:StartUpdatingComponent(self)
end, nil, {
    bonus = onbonus,
})

function StarIliadRainFXBonusWatcher:OnUpdate(dt)
    self.update_countdown = self.update_countdown - dt
    if self.update_countdown > 0 then
        return
    end
    self.update_countdown = 1

    local bonus = 0
    -- local sound_intensity = 0

    if TheWorld.components.stariliad_weather_lightning_storm then
        bonus = bonus + TheWorld.components.stariliad_weather_lightning_storm:GetRainFXBonus()
        -- sound_intensity = sound_intensity + TheWorld.components.stariliad_weather_lightning_storm:GetRainFXBonus()
    end

    self.bonus = bonus
    -- self.sound_intensity = sound_intensity
end

return StarIliadRainFXBonusWatcher
