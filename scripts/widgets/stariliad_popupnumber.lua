local Widget = require "widgets/widget"
local Text = require "widgets/text"

local StarIliadPopupNumber = Class(Widget,
    function(self, owner, val, size, pos, dir, height, colour, burst)
        Widget._ctor(self, "StarIliadPopupNumber")
        self.owner = owner
        self.text = self:AddChild(Text(NUMBERFONT, size, val ~= nil and tostring(val) or nil))
        self.pos = pos
        self.colour = colour
        self.rise = 24
        self.drop = 24
        self.speed = 68
        self.progress = 0
        self.burst = burst
        self.ts_step_1 = 3
        self.ts_step_2 = 2

        ----------------------------------------------------------
        local scale_factor = math.random() * 4
        self.dir = dir
        self.xoffs = scale_factor * dir.x
        self.yoffs = scale_factor * 0.5 * dir.y + height
        self.xoffs2 = 0
        self.yoffs2 = 0
        ----------------------------------------------------------

        self:SetClickable(false)
        self:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self:StartUpdating()
        self:OnUpdate(0)
    end
)

function StarIliadPopupNumber:OnUpdate(dt)
    if self.progress < 1 then
        self.progress = math.min(1, self.progress + dt * self.ts_step_1)

        local k = 1 - math.min(1, self.progress / .75)
        k = k * k
        self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * (1 - k * k))

        k = 1 - self.progress
        k = k * k
        k = 1 - k * k
        local offset = self.dir * self.speed * dt
        self.xoffs2 = self.xoffs2 + offset.x
        self.yoffs2 = k * self.rise + offset.y

        if self.burst then
            local s = 2 - k
            self:SetScale(s, s)
        end
    elseif self.progress < 2 then
        self.progress = math.min(2, self.progress + dt * self.ts_step_2)

        local k = math.max(0, self.progress - 1.1) / .9
        self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * (1 - k * k))

        k = self.progress - 1

        local offset = self.dir * self.speed * dt
        self.xoffs2 = self.xoffs2 + offset.x
        self.yoffs2 = self.rise - self.drop * k * k + offset.y
    else
        self:Kill()
        return
    end

    self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))
    self.text:SetPosition(self.xoffs + self.xoffs2, self.yoffs + self.yoffs2)
end

return StarIliadPopupNumber
