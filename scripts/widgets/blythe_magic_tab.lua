local Widget                   = require "widgets/widget"
local Image                    = require "widgets/image"
local Text                     = require "widgets/text"
local StarIliadScrollableText  = require "widgets/stariliad_scrollable_text"
local BlytheSkillSlot          = require "widgets/blythe_skill_slot"
local StarIliadKeyConfigDialog = require "screens/stariliad_key_config_dialog"

local TEMPLATES                = require "widgets/redux/templates"


-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.magic_tab.test_text:SetString("233555")
local BlytheMagicTab = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlytheMagicTab")

    self.owner = owner

    -- self.test_slot = self:AddChild(BlytheSkillSlot("configure_powersuit"))

    -- self.test_text = self:AddChild(StarIliadScrollableText({
    --     text_font = NUMBERFONT,
    --     text_size = 34,
    --     -- text_color = UICOLOURS.GOLD,
    --     text_width = 600,
    --     visible_height = 200,
    --     scroll_per_click = 20,
    -- }))

    -- self.test_text:SetString(StarIliadDebug.LOREM)

    self.options = {
        widget_width = 80,
        widget_height = 80,
        num_visible_rows = 6,
        num_columns = 8,
        bar_height = 550,
    }

    self.scroll_data = {}
    for _, v in pairs(BLYTHE_SKILL_DEFINES) do
        if v.dtype == BLYTHE_SKILL_TYPE.MAGIC then
            table.insert(self.scroll_data, {
                name = v.name,
            })
        end
    end

    self.title = self:AddChild(Text(TITLEFONT, 34))
    self.title:SetPosition(342, 250)
    -- self.title:SetColour(UICOLOURS.GOLD)

    self.description = self:AddChild(StarIliadScrollableText({
        text_font = NUMBERFONT,
        text_size = 28,
        text_color = UICOLOURS.GOLD_SELECTED,
        text_width = 280,
        visible_height = 500,
        scroll_per_click = 20,
    }))
    self.description:Hide()

    self.skill_key_config_button = self:AddChild(
        TEMPLATES.StandardButton(nil, STRINGS.STARILIAD_UI.MAGIC_TAB.KEY_CONFIG, { 140, 50 })
    )
    self.skill_key_config_button:Hide()
    self.skill_key_config_button:SetPosition(342, -240)

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(self.scroll_data, {
        context = {},
        widget_width = self.options.widget_width,
        widget_height = self.options.widget_height,
        num_visible_rows = self.options.num_visible_rows,
        num_columns = self.options.num_columns,
        peek_percent = 0.3,
        item_ctor_fn = function(context, i)
            local widget = BlytheSkillSlot()
            return widget
        end,
        apply_fn = function(context, widget, data, index)
            if widget == nil then
                return
            elseif data == nil then
                widget:Hide()
                return
            else
                widget:Show()
            end

            widget:SetSkillName(data.name)
            widget:EnableIcon(self.owner.replica.blythe_skiller:IsLearned(data.name))
            widget:SetOnClick(function()
                self:OnSkillSlotClick(widget)
            end)
        end,
        scrollbar_offset = 15,
        scrollbar_height_offset = 0
    }))
    self.scroll_list:SetPosition(-145, 0)
    self:ModifySlideBar()
end)

function BlytheMagicTab:OnSkillSlotClick(widget)
    if widget == nil or widget.skill_name == nil then
        return
    end

    local skill_name = widget.skill_name

    local define = StarIliadBasic.GetSkillDefine(skill_name)

    if define == nil then
        return
    end

    local title = skill_name
    local desc = skill_name

    local tab = STRINGS.STARILIAD_UI.SKILL_DETAIL[skill_name:upper()]

    if tab and tab.NAME then
        title = tab.NAME
        desc = tab.DESC
    end

    self.title:SetString(title)

    self.description:SetString(desc)
    self.description:Show()
    -- self.description:SetString(StarIliadDebug.LOREM)

    local _, h = self.description.text:GetRegionSize()
    self.description:SetPosition(340, 230 - h / 2)

    ---------------------------------------------------------

    local is_learned = self.owner.replica.blythe_skiller:IsLearned(skill_name)

    if is_learned and StarIliadBasic.IsCastByButton(skill_name) then
        self.skill_key_config_button:Show()
        self.skill_key_config_button:SetOnClick(function()
            TheFrontEnd:PushScreen(StarIliadKeyConfigDialog(self.owner, skill_name))
        end)
    else
        self.skill_key_config_button:Hide()
        self.skill_key_config_button:SetOnClick(nil)
    end
end

function BlytheMagicTab:ModifySlideBar()
    self.scroll_list.up_button:Hide()
    self.scroll_list.down_button:Hide()
    self.scroll_list.scroll_bar_container:Show()
    self.scroll_list.scroll_bar_line:Show()
    self.scroll_list.scroll_bar_line:ScaleToSize(11, self.options.bar_height)
    self.scroll_list.position_marker:Hide()
end

return BlytheMagicTab
