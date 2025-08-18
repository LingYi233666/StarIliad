local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"

local FADE_IN_TIME = 0.33
local FADE_OUT_TIME = 0.66

local StarIliadTipUI = Class(Widget, function(self, owner)
    Widget._ctor(self, "StarIliadTip")

    self.owner = owner

    self.text = self:AddChild(Text(UIFONT, 43))
    self.text:Hide()
end)

-- function StarIliadTipUI:ShowTip(str, duration)
--     if self.clean_task then
--         self.clean_task:Cancel()
--         self.clean_task = nil
--     end

--     self.text:Show()
--     self.text:SetString(str)

--     if duration and duration >= 0 then
--         self.clean_task = self.inst:DoTaskInTime(duration, function()
--             self.text:SetString("")
--             self.text:Hide()
--             self.clean_task = nil
--         end)
--     end
-- end

function StarIliadTipUI:ShowTip(str, duration)
    self.text:SetColour(1, 1, 1, 0)
    self.text:SetString(str)
    self.text:Show()

    self.duration = duration
    self.timer = GetTime()

    self:StartUpdating()
end

function StarIliadTipUI:OnUpdate()
    local duration = GetTime() - self.timer
    local alpha = 0
    if duration < FADE_IN_TIME then
        alpha = Remap(duration, 0, FADE_IN_TIME, 0, 1)
    elseif duration < self.duration - FADE_OUT_TIME then
        alpha = 1
    elseif duration < self.duration then
        alpha = Remap(duration, self.duration - FADE_OUT_TIME, self.duration, 1, 0)
    else
        self.text:SetString("")
        self.text:Hide()
        self:StopUpdating()
        return
    end

    self.text:SetColour(1, 1, 1, alpha)
end

return StarIliadTipUI
