local StarIliadImportantScanTarget = Class(function(self, inst)
    self.inst = inst

    self.reveal_time = 0
    self.max_reveal_time = 30

    self.add_indicator = false

    self.inst:StartUpdatingComponent(self)
end)

local HUD_INDICATOR_DATA = { image = "poi_question.tex", atlas = "images/avatars.xml" }


function StarIliadImportantScanTarget:OnEntitySleep() -- Master sim only.
    self.inst:StopUpdatingComponent(self)

    if ThePlayer and ThePlayer.HUD and self.add_indicator then
        ThePlayer.HUD:RemoveTargetIndicator(self.inst)
        self.add_indicator = false
    end
end

function StarIliadImportantScanTarget:OnEntityWake() -- Master sim only.
    self.inst:StartUpdatingComponent(self)
end

function StarIliadImportantScanTarget:OnUpdate(dt)
    if not (ThePlayer and ThePlayer.HUD) then
        return
    end

    local old_t = self.reveal_time
    if ThePlayer and ThePlayer:HasTag("blythe_skill_scan_pulse") then
        self.reveal_time = self.max_reveal_time
    else
        self.reveal_time = math.max(0, self.reveal_time - dt)
    end

    if old_t <= 0 and self.reveal_time > 0 and not self.add_indicator then
        ThePlayer.HUD:AddTargetIndicator(self.inst, HUD_INDICATOR_DATA)
        self.add_indicator = true
    elseif old_t > 0 and self.reveal_time <= 0 and self.add_indicator then
        ThePlayer.HUD:RemoveTargetIndicator(self.inst)
        self.add_indicator = false
    end
end

function StarIliadImportantScanTarget:OnRemoveEntity()
    self.inst:StopUpdatingComponent(self)

    if ThePlayer and ThePlayer.HUD and self.add_indicator then
        ThePlayer.HUD:RemoveTargetIndicator(self.inst)
        self.add_indicator = false
    end
end

StarIliadImportantScanTarget.OnRemoveFromEntity = StarIliadImportantScanTarget.OnRemoveEntity


return StarIliadImportantScanTarget
