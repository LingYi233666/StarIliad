local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local UIAnim = require "widgets/uianim"

local START_POS = Vector3(0, 0, 0)
local END_POS = Vector3(-400, 0, 0)

local BlytheTV = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlytheTV")

    self.owner = owner

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBuild("blythe_tv")
    self.anim:GetAnimState():SetBank("blythe_tv")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    -- self.anim:GetAnimState():SetSymbolMultColour("bg", 1, 1, 0, 1)
    -- self.anim:GetAnimState():SetSymbolMultColour("bg", 237/255,193/255,64/255, 1)
    self.anim:GetAnimState():SetSymbolMultColour("bg", 0.2, 0.2, 0.2, 1)
    self.anim:GetAnimState():SetDeltaTimeMultiplier(1.2)
    self.anim:SetScale(0.85)
    self.anim:Hide()

    self.inst:ListenForEvent("BlytheSkillSpeedBurst._in_speed_burst", function()
        if not TUNING.BLYTHE_TV_ENABLE then
            return
        end

        local cmp = self.owner.replica.blythe_skill_speed_burst
        -- print("BlytheSkillSpeedBurst._in_speed_burst trigger !")
        if cmp:IsInSpeedBurst() then
            -- print("In speed burst !")
            self:Push()
        else
            -- print("Not in speed burst !")

            self:Pop()
        end
    end, self.owner)
end)

function BlytheTV:Push()
    self.anim:CancelMoveTo()

    self.anim:Show()
    self.anim:MoveTo(self.anim:GetPosition(), END_POS, 0.66, function()

    end)
end

function BlytheTV:Pop()
    self.anim:CancelMoveTo()

    self.anim:Show()
    self.anim:MoveTo(self.anim:GetPosition(), START_POS, 0.66, function()
        self.anim:Hide()
    end)
end

return BlytheTV
