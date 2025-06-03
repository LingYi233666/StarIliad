local Widget                       = require "widgets/widget"
local Image                        = require "widgets/image"
local Text                         = require "widgets/text"
local Grid                         = require "widgets/grid"
local TEMPLATES                    = require "widgets/redux/templates"
local StarIliadScrollableText      = require "widgets/stariliad_scrollable_text"
local BlytheSkillSlot              = require "widgets/blythe_skill_slot"
local StarIliadKeyConfigDialog     = require "screens/stariliad_key_config_dialog"
local StarIliadHUDTimelineExecuter = require "widgets/stariliad_hud_timeline_executer"
local BlytheSkillUnlockFX          = require "widgets/blythe_skill_unlock_fx"



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

    -- self.scroll_data = {}
    -- for _, v in pairs(BLYTHE_SKILL_DEFINES) do
    --     if v.dtype == BLYTHE_SKILL_TYPE.MAGIC then
    --         table.insert(self.scroll_data, {
    --             name = v.name,
    --         })
    --     end
    -- end

    -- self.title = self:AddChild(Text(TITLEFONT, 34))
    self.title = self:AddChild(Text(NUMBERFONT, 34))
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


    self.skill_slots = {}
    for _, v in pairs(BLYTHE_SKILL_DEFINES) do
        if v.dtype == BLYTHE_SKILL_TYPE.MAGIC then
            local slot = self:AddChild(BlytheSkillSlot())
            slot:SetSkillName(v.name)
            slot:EnableIcon(self.owner.replica.blythe_skiller:IsLearned(v.name))
            slot:SetOnClick(function()
                self:OnSkillSlotClick(v.name)
                slot:EnableFlashing(false)
            end)

            table.insert(self.skill_slots, slot)
        end
    end

    self.grid = self:AddChild(Grid())
    self.grid:FillGrid(self.options.num_columns, self.options.widget_width, self.options.widget_height, self.skill_slots)
    self.grid:SetPosition(-438, 223)

    self.scroll_bar_line = self:AddChild(Image("images/global_redux.xml", "scrollbar_bar.tex"))
    self.scroll_bar_line:SetSize(11, self.options.bar_height)
    self.scroll_bar_line:SetPosition(185, 0)
end)

function BlytheMagicTab:OnSkillSlotClick(skill_name)
    local define = StarIliadBasic.GetSkillDefine(skill_name)

    if define == nil then
        return
    end

    local is_learned = self.owner.replica.blythe_skiller:IsLearned(skill_name)

    local title = skill_name
    local desc = skill_name

    if is_learned then
        local tab = STRINGS.STARILIAD_UI.SKILL_DETAIL[skill_name:upper()]

        if tab then
            title = tab.NAME
            desc = tab.DESC
        end
    else
        title = STRINGS.STARILIAD_UI.SKILL_DETAIL.UNKNOWN.NAME
        desc = STRINGS.STARILIAD_UI.SKILL_DETAIL.UNKNOWN.DESC
    end


    self.title:SetString(title)

    self.description:SetString(desc)
    self.description:Show()
    -- self.description:SetString(StarIliadDebug.LOREM)

    local _, h = self.description.text:GetRegionSize()
    self.description:SetPosition(340, 230 - h / 2)

    ---------------------------------------------------------


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

function BlytheMagicTab:FindItem(name)
    for _, v in pairs(self.skill_slots) do
        if v.skill_name == name then
            return v
        end
    end
end

function BlytheMagicTab:MakeItemsGray(skill_names)
    if type(skill_names) == "string" then
        skill_names = { skill_names }
    end

    for _, v in pairs(skill_names) do
        local item = self:FindItem(v)
        if item then
            item:EnableIcon(false)
        end
    end
end

local function MakeActivateItem(item, spawn_fx, shinning)
    if spawn_fx then
        local unlockfx = item:AddChild(BlytheSkillUnlockFX())
        unlockfx:SetScale(1.3, 1.3)
    end

    -- item:RefreshText()

    if shinning then
        item:EnableFlashing(true, 3)
    end

    item:EnableIcon(true)
end

local SG_play_learning_anim = {
    onenter = function(self, mem)
        mem.index = 1
        mem.period_run = 0

        self.te:SetTimeout(mem.period * (#mem.items + 2))
    end,

    onupdate = function(self, mem, dt)
        if mem.index > #(mem.items) then
            mem.finished = true
            return
        end

        mem.period_run = mem.period_run - dt
        if mem.period_run <= 0 then
            MakeActivateItem(mem.items[mem.index], true, true)

            mem.index = mem.index + 1
            mem.period_run = mem.period_run + mem.period
        end
    end,

    onexit = function(self, mem)
        self.te = nil
    end,


    timeline = {
        TimeEvent(25 * FRAMES, function(self, mem)
            if mem.show_desc then
                self:OnSkillSlotClick(mem.items[1].skill_name)
                self.last_click_item = mem.items[1]
            end
        end),
    },
}

function BlytheMagicTab:PlayLearningAnim(skill_names)
    self:InterruptLearningAnim()

    if type(skill_names) == "string" then
        skill_names = { skill_names }
    end

    local items = {}

    for _, v in pairs(skill_names) do
        local item = self:FindItem(v)
        if item then
            table.insert(items, item)
        end
    end

    local period = 15 * FRAMES

    self.te = self:AddChild(StarIliadHUDTimelineExecuter(self))
    self.te:SetFromTable(SG_play_learning_anim)

    self.te:Run({
        items = items,
        period = period,
        show_desc = (#items == 1),
    })
end

function BlytheMagicTab:InterruptLearningAnim()
    if self.te then
        self.te:Cancel()
    end
    self.te = nil
end

return BlytheMagicTab
