local HeaderTabs = require "widgets/redux/headertabs"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local SnapshotTab = require "widgets/redux/snapshottab"
local Subscreener = require "screens/redux/subscreener"
local TEMPLATES = require "widgets/redux/templates"
local TextListPopup = require "screens/redux/textlistpopup"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local NineSlice = require "widgets/nineslice"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local BlythePowersuitDisplay = require "widgets/blythe_powersuit_display"
local BlytheMagicTab = require "widgets/blythe_magic_tab"


local easing = require("easing")

local StarIliadMainMenu = Class(Screen, function(self, owner)
    Screen._ctor(self, "StarIliadMainMenu")

    self.owner = owner

    self.bg_width, self.bg_height = 900, 550

    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0, 0, 0, 0)
    self.black:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    self.black:MoveToBack()

    self.root = self:AddChild(TEMPLATES.ScreenRoot("StarIliadMainMenu"))

    self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(self.bg_width, self.bg_height))
    self.bg.top:Hide()
    self.bg.bottom:Hide()
    self.bg.mid_center:SetTint(unpack(UICOLOURS.BLACK))
    for i = 4, 5 do
        self.bg.elements[i]:SetTint(unpack(UICOLOURS.BLACK))
    end
    -- for i = 1, 3 do
    --     self.bg.elements[i]:SetTint(unpack(UICOLOURS.WHITE))
    -- end
    -- for i = 4, 5 do
    --     self.bg.elements[i]:SetTint(0 / 255, 37 / 255, 65 / 255, 1)
    -- end
    -- for i = 6, 8 do
    --     self.bg.elements[i]:SetTint(unpack(UICOLOURS.WHITE))
    -- end
    self.bg:SetPosition(0, -10)

    -- self.bg = self.root:AddChild(Image("images/global.xml", "square.tex"))
    -- self.bg:SetSize(self.bg_width, self.bg_height)
    -- self.bg:SetTint(0 / 255, 37 / 255, 65 / 255, 1)

    -- self.close_button = self.bg:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    -- self.close_button:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    -- self.close_button:SetPosition(self.bg_width / 2 + 35, self.bg_height / 2 + 35)

    self.tab_screens = {
        powersuit_display = self.bg:AddChild(BlythePowersuitDisplay(self.owner)),
        magic_tab = self.bg:AddChild(BlytheMagicTab(self.owner)),
    }

    self.headertab_screener = Subscreener(self,
        self._BuildHeaderTab, self.tab_screens
    )
    self.headertab_screener:OnMenuButtonSelected("powersuit_display")


    ThePlayer.HUD.controls.StarIliadMainMenu = self

    SetAutopaused(true)
end)

function StarIliadMainMenu:OnDestroy()
    SetAutopaused(false)

    ThePlayer.HUD.controls.StarIliadMainMenu = nil
    StarIliadMainMenu._base.OnDestroy(self)
end

function StarIliadMainMenu:_BuildHeaderTab(subscreener)
    local tabs = {
        { key = "powersuit_display", text = STRINGS.STARILIAD_UI.MAIN_MENU.SUB_TITLES.POWERSUIT_DISPLAY },
        { key = "magic_tab",         text = STRINGS.STARILIAD_UI.MAIN_MENU.SUB_TITLES.MAGIC_TAB },
    }

    -- local tabs = {}
    -- for index, _ in pairs(self.tab_screens) do
    --     table.insert(tabs, { key = index, text = STRINGS.STARILIAD_UI.MAIN_MENU.SUB_TITLES[string.upper(index)] })
    -- end

    self.header_tabs = self.bg:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    self.header_tabs:SetPosition(0, self.bg_height / 2 + 22)
    self.header_tabs:MoveToBack()
    local s = 0.8
    self.header_tabs:SetScale(s, s)

    return self.header_tabs.menu
end

function StarIliadMainMenu:SlideIn(duration, when_done)
    duration = duration or 1
    local start_pos = Vector3(0, -800)
    self.bg:SetPosition(start_pos)
    self.bg:MoveTo(start_pos, Vector3(0, 0), duration, when_done)
end

function StarIliadMainMenu:CancelSlideIn()
    self.bg:CancelMoveTo()
    self.bg:SetPosition(0, 0)
end

function StarIliadMainMenu:MakeItemsGray(skill_names)
    local is_suit = false
    local is_magic = false

    for _, v in pairs(skill_names) do
        local def = StarIliadBasic.GetSkillDefine(v)
        if def.dtype == BLYTHE_SKILL_TYPE.MAGIC then
            is_magic = true
        else
            is_suit = true
        end
    end

    if is_suit and is_magic then
        print("Can't make items gray !!!")
    elseif is_suit then
        self.headertab_screener:OnMenuButtonSelected("powersuit_display")
        self.tab_screens.powersuit_display:MakeItemsGray(skill_names)
    elseif is_magic then
        self.headertab_screener:OnMenuButtonSelected("magic_tab")
        self.tab_screens.magic_tab:MakeItemsGray(skill_names)
    end
end

function StarIliadMainMenu:PlayLearningAnim(skill_names)
    local is_suit = false
    local is_magic = false

    for _, v in pairs(skill_names) do
        local def = StarIliadBasic.GetSkillDefine(v)
        if def.dtype == BLYTHE_SKILL_TYPE.MAGIC then
            is_magic = true
        else
            is_suit = true
        end
    end

    if is_suit and is_magic then
        print("Can't play learning anim !!!")
    elseif is_suit then
        self.headertab_screener:OnMenuButtonSelected("powersuit_display")
        self.tab_screens.powersuit_display:PlayLearningAnim(skill_names)
    elseif is_magic then
        self.headertab_screener:OnMenuButtonSelected("magic_tab")
        self.tab_screens.magic_tab:PlayLearningAnim(skill_names)
    end
end

function StarIliadMainMenu:InterruptLearningAnim()
    self.tab_screens.powersuit_display:InterruptLearningAnim()
    self.tab_screens.magic_tab:InterruptLearningAnim()
end

function StarIliadMainMenu:OnControl(control, down)
    if StarIliadMainMenu._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_CANCEL) then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function StarIliadMainMenu:OnUpdate()

end

return StarIliadMainMenu
