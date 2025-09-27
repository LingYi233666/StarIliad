local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local StarIliadMainMenu = require "screens/stariliad_main_menu"
local BlytheMissileStatus = require "widgets/blythe_missile_status"
local BlytheTV = require "widgets/blythe_tv"
local StarIliadTipUI = require "widgets/stariliad_tip_ui"
local StariliadShakingText = require "widgets/stariliad_shaking_text"

AddClassPostConstruct("widgets/controls", function(self)
    if self.owner:HasTag("blythe") then
        self.StarIliadMenuCaller_root = self:AddChild(Widget("StarIliadMenuCaller_root"))
        self.StarIliadMenuCaller_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.StarIliadMenuCaller_root:SetHAnchor(ANCHOR_LEFT)
        self.StarIliadMenuCaller_root:SetVAnchor(ANCHOR_BOTTOM)
        self.StarIliadMenuCaller_root:SetMaxPropUpscale(MAX_HUD_SCALE)

        self.StarIliadMenuCaller = self.StarIliadMenuCaller_root:AddChild(
            TEMPLATES.StandardButton(
                function()
                    local main_menu = StarIliadMainMenu(self.owner)
                    TheFrontEnd:PushScreen(main_menu)
                end,
                STRINGS.STARILIAD_UI.MAIN_MENU.CALLER_TEXT,
                { 140, 60 }
            )
        )

        self.StarIliadMenuCaller:SetPosition(75, 28)


        -- Blythe TV
        self.BlytheTV = self.topright_root:AddChild(BlytheTV(self.owner))
        self.BlytheTV:SetPosition(100, -120)
        self.BlytheTV:MoveToBack()

        -- Tips
        self.StarIliadTipUI = self.bottom_root:AddChild(StarIliadTipUI(self.owner))
        self.StarIliadTipUI:SetPosition(0, 150)


        -- self.test_shaking_text = self.owner.HUD:AddChild(StariliadShakingText(TALKINGFONT, 50,
        --     STRINGS.STARILIAD_NPC_SPEECH.STARILIAD_BOSS_GUARDIAN.DESTROY3, { 238 / 255, 69 / 255, 105 / 255, 1 }))
        -- -- self.test_shaking_text:SetPosition(0, 300)
        -- self.test_shaking_text:SetTarget(self.owner, "head_base", Vector3(0, -500, 0))
    end
end)

AddClassPostConstruct("widgets/secondarystatusdisplays", function(self)
    if self.owner:HasTag("blythe") then
        self.blythe_missile_status = self:AddChild(BlytheMissileStatus(self.owner))
        self.blythe_missile_status:SetPosition(60, -80)
        self.blythe_missile_status:MoveToFront()
    end
end)
