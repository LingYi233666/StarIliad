local Widget = require "widgets/widget"
local Image = require "widgets/image"
local BlytheSkillList = require "widgets/blythe_skill_list"
local BlytheSkillDesc = require "widgets/blythe_skill_desc"
local BlytheSkillActiveFX = require "widgets/blythe_skill_active_fx"
local StarIliadHUDTimelineExecuter = require "widgets/stariliad_hud_timeline_executer"

local BlythePowersuitDisplay = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlythePowersuitDisplay")

    self.owner = owner

    self.lists = {
        [BLYTHE_SKILL_TYPE.ENERGY] = self:CreateSkillList(BLYTHE_SKILL_TYPE.ENERGY),
        [BLYTHE_SKILL_TYPE.KINETIC] = self:CreateSkillList(BLYTHE_SKILL_TYPE.KINETIC, 250),
        [BLYTHE_SKILL_TYPE.SUIT] = self:CreateSkillList(BLYTHE_SKILL_TYPE.SUIT),
    }

    self.lists[BLYTHE_SKILL_TYPE.ENERGY]:SetPosition(-350, 100)
    self.lists[BLYTHE_SKILL_TYPE.KINETIC]:SetPosition(-325, -120)
    self.lists[BLYTHE_SKILL_TYPE.SUIT]:SetPosition(350, 150)

    self.skill_desc = self:AddChild(BlytheSkillDesc({
        width = 900,
        height = 90,
        space_width = 5,
        space_height = 8,
    }))
    self.skill_desc:SetPosition(0, -220)

    for _, l in pairs(self.lists) do
        for _, v in pairs(l.items) do
            v:SetOnClick(function()
                self:ShowSkillDescription(v.skill_name)
                v:RefreshText()
            end)
        end
    end

    -- self.inst:SetStateGraph("SGblythe_powersuit_display")
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

    if widget_width == nil then
        widget_width = 200
    end

    if widget_height == nil then
        widget_height = #skills_data * 35 + SPACE_HEIGHT * 2
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

function BlythePowersuitDisplay:ShowSkillDescription(skill_name)
    local text = STRINGS.STARILIAD_UI.SKILL_DETAIL[skill_name:upper()].DESC
    self.skill_desc:SetText(text)
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

---------------------------------------------------------------------

local function MakeGrayItem(item)
    item.text_button:SetColour(0.3, 0.3, 0.3, 1)
    item.text_button:SetClickable(false)
    item.block:SetTint(unpack(UICOLOURS.GREY))
end

local function MakeActivateItem(item, spawn_fx, shinning)
    if spawn_fx then
        local active_fx = item.block:AddChild(BlytheSkillActiveFX())
        active_fx:SetPosition(0, 15)
    end

    item:RefreshText()

    if shinning then
        item.block:StartShinning()
    end
end

local function onenter(self, mem)
    MakeGrayItem(mem.item)
end

local function onexit(self, mem)
    -- MakeActivateItem(mem.item, true, true)
end

local timeline = {
    TimeEvent(20 * FRAMES, function(self, mem)
        MakeActivateItem(mem.item, true, true)

        TheFocalPoint.SoundEmitter:PlaySound("wilson_rework/ui/skill_mastered")
    end),

    TimeEvent(34 * FRAMES, function(self, mem)
        if mem.show_desc then
            self:ShowSkillDescription(mem.item.skill_name)
        end
    end),
}

-- ThePlayer.HUD.controls.StarIliadMainMenu.tab_screens.powersuit_display:PlayLearningAnim("basic_beam")
function BlythePowersuitDisplay:PlayLearningAnim(skill_name)
    -- local skill_def = StarIliadBasic.GetSkillDefine(skill_name)
    -- if not skill_def or not skill_def.dtype then
    --     print("Def not found !")
    --     return
    -- end

    -- local target_list = self.lists[skill_def.dtype]

    -- if not target_list then
    --     print("List not found !")
    --     return
    -- end

    -- local target_item = target_list:GetItemBySkillName(skill_name)
    -- if not target_item then
    --     print("Item not found !")
    --     return
    -- end

    local item = self:FindItem(skill_name)
    if not item then
        return
    end

    self.te = self:AddChild(StarIliadHUDTimelineExecuter(self))
    self.te:SetOnEnterFn(onenter)
    self.te:SetOnExitFn(onexit)
    self.te:SetTimeline(timeline)
    self.te:Run({ item = item, show_desc = true })

    -- local mem_override = {
    --     list = target_list,
    --     item = target_item,
    --     skill_name = skill_name,
    -- }

    -- self.te:Run(mem_override)

    -- print("fun !")
    -- if type(skill_names) == "string" then
    --     skill_names = { skill_names }
    -- end
    -- self.inst:PushEvent("play_skill_learning_anim", { skill_names = skill_names })
end

function BlythePowersuitDisplay:EndLearningAnim(interrupt)
    if self.te then
        self.te:Cancel()
    end
    self.te = nil
end

return BlythePowersuitDisplay
