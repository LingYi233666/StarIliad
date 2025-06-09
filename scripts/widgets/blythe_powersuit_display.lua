local Widget = require "widgets/widget"
local Image = require "widgets/image"
local BlytheSkillList = require "widgets/blythe_skill_list"
local BlytheSkillDesc = require "widgets/blythe_skill_desc"
local BlytheSkillActiveFX = require "widgets/blythe_skill_active_fx"
local StarIliadHUDTimelineExecuter = require "widgets/stariliad_hud_timeline_executer"
local BlytheGridBG = require "widgets/blythe_grid_bg"
local StarIliadPolyLines = require "widgets/stariliad_polylines"

-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.character:SetPosition(0,50)
-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.character_bg:SetSize(200, 400)
-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.character:SetTint(0.3,0.3,0.3,1)
-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.polylines_1:SetPosition(-100,100)
-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.polylines_2:SetPosition(-100,-100)
-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display.polylines_3:SetPosition(100,100)
local BlythePowersuitDisplay = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlythePowersuitDisplay")

    self.owner = owner

    self.grid_bg = self:AddChild(BlytheGridBG({
        width = 975,
        height = 550,
        num_steps_hor = 36,
        num_steps_vert = 22,

        up_down_bar_width = 1,
        up_down_bar_color = { 0 / 255, 115 / 255, 111 / 255, 0.5 },
        -- up_down_bar_color = { 0 / 255, 91 / 255, 90 / 255, 1 },
        left_right_bar_height = 1,
        left_right_bar_color = { 9 / 255, 77 / 255, 64 / 255, 0.5 },
        -- left_right_bar_color = UICOLOURS.BROWN_DARK,

        ignore_edge = true,
    }))

    -- self.character_bg = self:AddChild(Image("images/global.xml", "square.tex"))
    -- -- self.character_bg:SetTint(143 / 255, 147 / 255, 158 / 255, 0.7)
    -- -- self.character_bg:SetTint(175 / 255, 175 / 255, 50 / 255, 0.7)
    -- -- self.character_bg:SetTint(50 / 255, 150 / 255, 150 / 255, 0.7)
    -- -- self.character_bg:SetTint(200 / 255, 10 / 255, 200 / 255, 0.7)
    -- self.character_bg:SetTint(0 / 255, 0 / 255, 0 / 255, 0.7)
    -- self.character_bg:SetSize(300, 400)
    -- self.character_bg:SetPosition(0, 50)


    self.character_bg_fill = self:AddChild(Image("images/ui/stariliad_honeycomb_fill.xml", "stariliad_honeycomb_fill.tex"))
    self.character_bg_fill:SetTint(0 / 255, 37 / 255, 65 / 255, 1)
    -- self.character_bg_fill:SetTint(0 / 255, 22 / 255, 40 / 255, 1)
    self.character_bg_fill:SetPosition(0, 50)
    self.character_bg_fill:SetScale(0.55)

    self.character_bg = self:AddChild(Image("images/ui/stariliad_honeycomb.xml", "stariliad_honeycomb.tex"))
    -- self.character_bg:SetTint(200 / 255, 50 / 255, 150 / 255, 0.7)
    self.character_bg:SetTint(0 / 255, 127 / 255, 127 / 255, 1)
    self.character_bg:SetPosition(0, 50)
    self.character_bg:SetScale(0.55)

    -- self.character_old = self:AddChild(Image("images/ui/blythe_down_view.xml", "blythe_down_view.tex"))
    -- self.character_old:SetScale(0.27)
    -- self.character_old:SetPosition(0, 50)

    self.character = self:AddChild(Image("images/ui/blythe_down_view_with_gun.xml", "blythe_down_view_with_gun.tex"))
    self.character:SetScale(0.93828)
    self.character:SetPosition(-12, 50)

    -- self.character:Hide()
    -- self.character:SetTint(0.1, 0.7, 0.5, 1)
    -- self.character:SetTint(0.1, 0.1, 0.1, 1)
    -- self.character:SetTint(0.7, 0.7, 0.7, 1)
    -- self.character:SetTint(0.9, 0.1, 0.1, 1)

    -- local polylines_color = RGB(200, 170, 80)
    local polylines_color = RGB(167, 144, 88)
    -- local polylines_color = RGB(50, 200, 50)
    local polylines_thickness = 3

    self.polylines_1 = self:AddPolylines({
        points = {
            Vector3(0, 0),
            Vector3(100, 0),
            -- Vector3(190, -160),
            Vector3(170, -180),

            -- Vector3(0, 0),
            -- Vector3(90, 0),
            -- Vector3(90, -180),
            -- Vector3(170, -180),
        },

        color = polylines_color,

        thickness = polylines_thickness,
    }, Vector3(-250, 228)) -- Vector3(-250, 243)


    self.polylines_2 = self:AddPolylines({
        points = {
            Vector3(0, 0),
            Vector3(50, 0),
            -- Vector3(140, 100),
            Vector3(110, 95),

            -- Vector3(0, 0),
            -- Vector3(60, 0),
            -- Vector3(60, 90),
            -- Vector3(110, 90),
        },

        color = polylines_color,

        thickness = polylines_thickness,
    }, Vector3(-200, -62)) -- Vector3(-200, -30)

    self.polylines_3 = self:AddPolylines({
        points = {
            Vector3(0, 0),
            Vector3(-120, 0),
            Vector3(-240, -80),
            -- Vector3(140, 100),
            -- Vector3(-240, -95),
        },

        color = polylines_color,

        thickness = polylines_thickness,
    }, Vector3(248, 207)) -- Vector3(248, 222)

    -- self.polylines_1:Hide()
    -- self.polylines_2:Hide()
    -- self.polylines_3:Hide()

    -- self.test_bar = self:AddChild(Image("images/global.xml", "square.tex"))
    -- self.test_bar:SetTint(unpack(UICOLOURS.BROWN_MEDIUM))
    -- self.test_bar:SetSize(400, 5)
    -- RGB(136,102,63) ?


    self.lists = {
        [BLYTHE_SKILL_TYPE.ENERGY] = self:CreateSkillList(BLYTHE_SKILL_TYPE.ENERGY),
        [BLYTHE_SKILL_TYPE.KINETIC] = self:CreateSkillList(BLYTHE_SKILL_TYPE.KINETIC, 250),
        [BLYTHE_SKILL_TYPE.SUIT] = self:CreateSkillList(BLYTHE_SKILL_TYPE.SUIT),
    }

    self.lists[BLYTHE_SKILL_TYPE.ENERGY]:SetPosition(-350, 100)
    self.lists[BLYTHE_SKILL_TYPE.KINETIC]:SetPosition(-325, -120)
    self.lists[BLYTHE_SKILL_TYPE.SUIT]:SetPosition(350, 150)
    -- self.lists[BLYTHE_SKILL_TYPE.ENERGY]:SetPosition(-350, 115)
    -- self.lists[BLYTHE_SKILL_TYPE.KINETIC]:SetPosition(-325, -105)
    -- self.lists[BLYTHE_SKILL_TYPE.SUIT]:SetPosition(350, 165)

    self.skill_desc = self:AddChild(BlytheSkillDesc({
        width = 900,
        height = 90,
        space_width = 5,
        space_height = 8,
    }))
    self.skill_desc:SetPosition(0, -220)

    self.last_click_item = nil

    for _, l in pairs(self.lists) do
        for _, v in pairs(l.items) do
            v:SetOnClick(function()
                if self.last_click_item == v then
                    self:ShowSkillDescription(v.skill_name)
                    self.last_click_item = nil
                else
                    self:ShowSkillDescription(v.skill_name, true)
                    self.last_click_item = v
                end
                self:InterruptLearningAnim()
                v:RefreshText()
            end)
        end
    end
end)

function BlythePowersuitDisplay:CreateSkillList(dtype, widget_width, widget_height)
    if BLYTHE_SKILL_TYPE[dtype] == nil then
        return
    end

    local skills_data = {}
    for _, v in pairs(BLYTHE_SKILL_DEFINES) do
        if v.dtype == dtype then
            table.insert(skills_data, { name = v.name })
        end
    end

    local SPACE_HEIGHT = 5
    local PER_HEIGHT = 35
    -- local PER_HEIGHT = 30


    if widget_width == nil then
        widget_width = 200
    end

    if widget_height == nil then
        widget_height = #skills_data * PER_HEIGHT + SPACE_HEIGHT * 2
    end


    local options = {
        width = widget_width,
        height = widget_height,
        space_width = 8,
        space_height = SPACE_HEIGHT,
        skills_data = skills_data,
        title = STRINGS.STARILIAD_UI.BLYTHE_SKILL_TYPE_NAME[dtype],
    }
    local item = self:AddChild(BlytheSkillList(self.owner, options))

    return item
end

function BlythePowersuitDisplay:ShowSkillDescription(skill_name, slide)
    local text = STRINGS.STARILIAD_UI.SKILL_DETAIL[skill_name:upper()].DESC

    if slide then
        self.skill_desc:SlideShowText(text)
    else
        self.skill_desc:CancelSlideShowText()
        self.skill_desc:SetText(text)
    end
end

function BlythePowersuitDisplay:FindItem(skill_name)
    local skill_def = StarIliadBasic.GetSkillDefine(skill_name)
    if not skill_def or not skill_def.dtype then
        print("Def not found !")
        return
    end

    local target_list = self.lists[skill_def.dtype]

    if not target_list then
        print("List not found !")
        return
    end

    local target_item = target_list:GetItemBySkillName(skill_name)
    if not target_item then
        print("Item not found !")
        return
    end

    return target_item
end

function BlythePowersuitDisplay:AddPolylines(options, pos)
    local polylines = self:AddChild(StarIliadPolyLines(options))
    polylines:SetPosition(pos)
    polylines.circle_final = polylines:DrawCircle(options.points[#(options.points)], 7, options.color)

    return polylines
end

---------------------------------------------------------------------

local function MakeGrayItem(item)
    item.text_button:SetColour(0.3, 0.3, 0.3, 1)
    item.text_button:SetClickable(false)
    item.block:SetTint(unpack(UICOLOURS.GREY))
end

local function MakeActivateItem(item, spawn_fx, shinning)
    if spawn_fx then
        local active_fx = item.block:AddChild(BlytheSkillActiveFX())
    end

    item:RefreshText()

    if shinning then
        item.block:StartShinning()
    end
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
                self:ShowSkillDescription(mem.items[1].skill_name, true)
                self.last_click_item = mem.items[1]
            end
        end),
    },
}



-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display:PlayLearningAnim("basic_beam")
-- function BlythePowersuitDisplay:PlayLearningAnim(skill_name)
--     local item = self:FindItem(skill_name)
--     if not item then
--         return
--     end

--     self.te = self:AddChild(StarIliadHUDTimelineExecuter(self))
--     self.te:SetOnEnterFn(onenter)
--     self.te:SetOnUpdateFn(onupdate)
--     self.te:SetTimeline(timeline)
--     self.te:SetTimeout(1)
--     self.te:Run({ item = item, show_desc = true })
-- end

function BlythePowersuitDisplay:MakeItemsGray(skill_names)
    if type(skill_names) == "string" then
        skill_names = { skill_names }
    end

    for _, v in pairs(skill_names) do
        local item = self:FindItem(v)
        if item then
            MakeGrayItem(item)
        end
    end
end

function BlythePowersuitDisplay:PlayLearningAnim(skill_names)
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

function BlythePowersuitDisplay:InterruptLearningAnim()
    if self.te then
        self.te:Cancel()
    end
    self.te = nil
end

return BlythePowersuitDisplay
