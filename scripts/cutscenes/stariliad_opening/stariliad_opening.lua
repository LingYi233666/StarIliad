local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local StarIliadOpeningPart1 = require "cutscenes/stariliad_opening/part1"
local StarIliadOpeningPart2 = require "cutscenes/stariliad_opening/part2"
local StarIliadOpeningPart3 = require "cutscenes/stariliad_opening/part3"
local StarIliadOpeningPart4 = require "cutscenes/stariliad_opening/part4"
local StarIliadOpeningPart5 = require "cutscenes/stariliad_opening/part5"

local StarIliadOpening = Class(Screen, function(self)
    Screen._ctor(self, "StarIliadOpening")

    self.root = self:AddChild(TEMPLATES.ScreenRoot("StarIliadOpening"))

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 1)

    self.parts = {
        self.root:AddChild(StarIliadOpeningPart1()),
        self.root:AddChild(StarIliadOpeningPart2()),
        self.root:AddChild(StarIliadOpeningPart3()),
        self.root:AddChild(StarIliadOpeningPart4()),
        self.root:AddChild(StarIliadOpeningPart5()),
    }

    for k, v in pairs(self.parts) do
        if k ~= 1 then
            v:Hide()
        end
    end

    ---------------------------------------------------------------
    self.exit_button = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.exit_button.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.exit_button.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.exit_button.image:SetVAnchor(ANCHOR_MIDDLE)
    self.exit_button.image:SetHAnchor(ANCHOR_MIDDLE)
    self.exit_button.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.exit_button.image:SetTint(0, 0, 0, 0)
    self.exit_button:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    self.exit_button:MoveToFront()
    ---------------------------------------------------------------

    StarIliadDebug.CUTSCENE = self

    SetAutopaused(true)
    ---------------------------------------------------------------

    self:Play()
end)

function StarIliadOpening:AddBlackHover()
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 0 }, { r = 0, g = 0, b = 0, a = 1 }, 1)
end

function StarIliadOpening:RemoveBlackHover()
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 1 }, { r = 0, g = 0, b = 0, a = 0 }, 1)
end

function StarIliadOpening:FlashBlackHover()
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 0 }, { r = 0, g = 0, b = 0, a = 1 }, 1, function()
        self.black:TintTo({ r = 0, g = 0, b = 0, a = 1 }, { r = 0, g = 0, b = 0, a = 0 }, 1)
    end)
end

function StarIliadOpening:Play()
    TheFrontEnd:GetSound():PlaySound("stariliad_music/music/cutscene_opening", "cutscene_opening")

    self:RemoveBlackHover()
    self.parts[1]:Play()

    self.inst:DoTaskInTime(15.8, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(16.8, function()
        self.parts[1]:Hide()
        self.parts[2]:Show()
        self.parts[2]:Play()
    end)

    self.inst:DoTaskInTime(25, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(26, function()
        self.parts[2]:Hide()
        self.parts[3]:Show()
        self.parts[3]:Play()
    end)

    self.inst:DoTaskInTime(32, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(33, function()
        self.parts[3]:Hide()
        self.parts[4]:Show()
        self.parts[4]:Play()
    end)

    self.inst:DoTaskInTime(39, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(40, function()
        self.parts[4]:Hide()
        self.parts[5]:Show()
        self.parts[5]:Play()
    end)

    -------------------------------------------------------
    -- self:RemoveBlackHover()
    -- self.parts[1]:Hide()
    -- self.parts[2]:Hide()
    -- self.parts[3]:Hide()
    -- self.parts[4]:Hide()
    -- self.parts[5]:Show()
    -- self.parts[5]:Play()

    -- self.parts[2]:Show()
    -- -- self.parts[2]:Play()
    -- self.parts[3]:Hide()
    -- -- self.parts[3]:Play()
end

function StarIliadOpening:OnDestroy()
    SetAutopaused(false)

    TheFrontEnd:GetSound():KillSound("cutscene_opening")

    StarIliadDebug.CUTSCENE = nil
    StarIliadOpening._base.OnDestroy(self)
end

return StarIliadOpening
