local StarIliadRainFXBonusWatcher = Class(function(self, inst)
    self.inst = inst

    self._bonus = net_ushortint(inst.GUID, "StarIliadRainFXBonusWatcher._bonus")
    self._bonus:set(0)

    self.rainfx = nil
    self.update_countdown = 0


    self.inst:StartUpdatingComponent(self)
end)

function StarIliadRainFXBonusWatcher:SetRainFXBonus(val)
    self._bonus:set(math.floor(val))
end

function StarIliadRainFXBonusWatcher:OnUpdate(dt)
    if ThePlayer ~= self.inst then
        return
    end

    if not (self.rainfx and self.rainfx:IsValid()) then
        self.update_countdown = self.update_countdown - dt
        if self.update_countdown > 0 then
            return
        end
        self.update_countdown = 1

        for _, v in pairs(Ents) do
            if v.prefab == "rain" then
                self.rainfx = v
                break
            end
        end
    end

    if not (self.rainfx and self.rainfx:IsValid()) then
        return
    end

    -- self.rainfx.num_particles_to_emit = inst.particles_per_tick
    -- self.rainfx.num_splashes_to_emit = 0

    local bonus = self._bonus:value()

    self.rainfx.num_particles_to_emit = self.rainfx.num_particles_to_emit + bonus * dt
    self.rainfx.num_splashes_to_emit = self.rainfx.num_splashes_to_emit + bonus * dt / 2

    if bonus > 0 then
        if not TheWorld.SoundEmitter:PlayingSound("stariliad_rain_bonus") then
            TheWorld.SoundEmitter:PlaySound("dontstarve/AMB/rain", "stariliad_rain_bonus")
        end
        TheWorld.SoundEmitter:SetParameter("stariliad_rain_bonus", "intensity", math.clamp(bonus / 200, 0.1, 1))
    elseif bonus <= 0 and TheWorld.SoundEmitter:PlayingSound("stariliad_rain_bonus") then
        TheWorld.SoundEmitter:KillSound("stariliad_rain_bonus")
    end
end

return StarIliadRainFXBonusWatcher
