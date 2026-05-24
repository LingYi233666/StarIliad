local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local StarIliadOpeningAVGN = Class(Screen, function(self)
    Screen._ctor(self, "StarIliadOpeningAVGN")

    self.root = self:AddChild(TEMPLATES.ScreenRoot("StarIliadOpeningAVGN"))

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0)

    self.bg = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.bg:SetTint(0, 0, 0, 1)
    self.bg:Hide()

    self.anim_image = self.root:AddChild(UIAnim())
    self.anim_image:GetAnimState():SetBank("stariliad_cutscene_opening_avgn")
    self.anim_image:GetAnimState():SetBuild("stariliad_cutscene_opening_avgn")
    -- self.anim_image:GetAnimState():PlayAnimation("idle", true)
    self.anim_image:GetAnimState():UsePointFiltering(true)
    self.anim_image:SetScale(1.2)
    self.anim_image:SetPosition(0, 50)

    self.text = self.root:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    -- self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[3], 99999, 900)
    self.text:SetPosition(0, 100)
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

    TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/ding_avgn")
    self:AddBlackHover(3.5)

    self.inst:DoTaskInTime(4, function()
        self:Play()
    end)
end)

function StarIliadOpeningAVGN:AddBlackHover(duration)
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 0 }, { r = 0, g = 0, b = 0, a = 1 }, duration or 0.5)
end

function StarIliadOpeningAVGN:RemoveBlackHover(duration)
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 1 }, { r = 0, g = 0, b = 0, a = 0 }, duration or 0.5)
end

function StarIliadOpeningAVGN:FlashBlackHover()
    self.black:TintTo({ r = 0, g = 0, b = 0, a = 0 }, { r = 0, g = 0, b = 0, a = 1 }, 0.5, function()
        self.black:TintTo({ r = 0, g = 0, b = 0, a = 1 }, { r = 0, g = 0, b = 0, a = 0 }, 0.5)
    end)
end

function StarIliadOpeningAVGN:RollingText(text)
    self.text:SetMultilineTruncatedString(text, 99999, 800)
    -- self.text:SetPosition(0, 100)
end

function StarIliadOpeningAVGN:Play()
    TheFrontEnd:GetSound():PlaySound("stariliad_music/music/cutscene_opening_avgn", "cutscene_opening")

    self:RemoveBlackHover()
    self.bg:Show()

    self.anim_image:GetAnimState():PlayAnimation("imgs1")
    self:RollingText(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[1]:format(GetRandomItem(STRINGS.STARILIAD_UI.CUTSCENES
        .INTRO_AVGN_SHITTY_GAMES)))

    self.inst:DoTaskInTime(7, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(7.5, function()
        self.anim_image:GetAnimState():PlayAnimation("imgs2")
        self:RollingText(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[2])
    end)

    self.inst:DoTaskInTime(15, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(15.5, function()
        self.anim_image:GetAnimState():PlayAnimation("imgs3")
        self:RollingText(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[3])
    end)

    self.inst:DoTaskInTime(23, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(23.5, function()
        self.anim_image:GetAnimState():PlayAnimation("imgs4")
        self:RollingText(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[4])
    end)

    self.inst:DoTaskInTime(31, function()
        self:FlashBlackHover()
    end)

    self.inst:DoTaskInTime(31.5, function()
        self.anim_image:GetAnimState():PlayAnimation("imgs5")
        self:RollingText(STRINGS.STARILIAD_UI.CUTSCENES.INTRO_AVGN[5])
    end)
end

function StarIliadOpeningAVGN:OnDestroy()
    SetAutopaused(false)

    TheFrontEnd:GetSound():KillSound("cutscene_opening")

    StarIliadDebug.CUTSCENE = nil
    StarIliadOpeningAVGN._base.OnDestroy(self)
end

return StarIliadOpeningAVGN
