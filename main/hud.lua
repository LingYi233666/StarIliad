local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local StarIliadMainMenu = require "screens/stariliad_main_menu"

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
    end
end)
