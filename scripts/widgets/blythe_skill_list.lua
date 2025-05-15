local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local BlytheSkillListItem = require "widgets/blythe_skill_list_item"

local TEMPLATES = require "widgets/redux/templates"

local BlytheSkillList = Class(Widget, function(self, owner, options)
    Widget._ctor(self, "BlytheSkillList")

    self.owner = owner
    self.options = options

    -- skills_data = {
    --     { name = "name", }
    -- }

    self:GenerateMoreOptions()

    -- self.bg = self:AddChild(TEMPLATES.RectangleWindow(width, height))

    self.bg = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetSize(self.options.width, self.options.height)
    self.bg:SetTint(0, 0, 0, 1)
    -- self.bg:Hide()

    self:CreateOutBarAndTitle()


    self.grid = self:AddChild(Grid())
    self:FullfilGrids()
end)

function BlytheSkillList:GenerateMoreOptions()
    self.options.grid_height = self.options.height - 2 * self.options.space_height
    self.options.grid_width = self.options.width - 2 * self.options.space_width
end

function BlytheSkillList:CreateOutBarAndTitle()
    local side_bar_width = 3

    local down_bar_width = self.options.width + side_bar_width * 2
    local down_bar_height = 3

    local up_bar_width = self.options.width + side_bar_width * 2
    local up_bar_height = 33

    local bar_color = UICOLOURS.BROWN_MEDIUM

    self.left_bar = self:AddChild(Image("images/global.xml", "square.tex"))
    self.left_bar:SetTint(unpack(bar_color))
    self.left_bar:SetPosition(-self.options.width / 2 - side_bar_width / 2, 0)
    self.left_bar:SetSize(side_bar_width, self.options.height)
    -- self.left_bar:MoveToBack()

    self.right_bar = self:AddChild(Image("images/global.xml", "square.tex"))
    self.right_bar:SetTint(unpack(bar_color))
    self.right_bar:SetPosition(self.options.width / 2 + side_bar_width / 2, 0)
    self.right_bar:SetSize(side_bar_width, self.options.height)
    -- self.right_bar:MoveToBack()

    self.down_bar = self:AddChild(Image("images/global.xml", "square.tex"))
    self.down_bar:SetTint(unpack(bar_color))
    self.down_bar:SetPosition(0, -self.options.height / 2 - down_bar_height / 2)
    self.down_bar:SetSize(down_bar_width, down_bar_height)
    -- self.down_bar:MoveToBack()

    self.up_bar = self:AddChild(Image("images/global.xml", "square.tex"))
    self.up_bar:SetTint(unpack(bar_color))
    self.up_bar:SetPosition(0, self.options.height / 2 + up_bar_height / 2)
    self.up_bar:SetSize(up_bar_width, up_bar_height)

    -- self.dtype_bar = self:AddChild(Image("images/ui/stariliad_dtype_bg.xml", "stariliad_dtype_bg.tex"))
    -- self.dtype_bar:SetTint(107 / 255, 67 / 255, 42 / 255, 1)
    -- self.dtype_bar:SetPosition(0, self.options.height / 2 + up_bar_height / 2)
    -- self.dtype_bar:SetSize(0, up_bar_height)


    self.upright_corner = self:AddChild(Image("images/ui/stariliad_bg_upright.xml", "stariliad_bg_upright.tex"))
    -- self.upright_corner:SetTint(107 / 255, 67 / 255, 42 / 255, 1)
    self.upright_corner:SetTint(73 / 255, 44 / 255, 25 / 255, 1)


    -----------------------------------------------------------------------------

    self.title = self:AddChild(Text(TITLEFONT, 34))
    self.title:SetString(self.options.title)

    local w, h = self.title:GetRegionSize()
    self.title:SetPosition(-self.options.width / 2 + w / 2 + 5, self.options.height / 2 + h / 2 + 3)

    -----------------------------------------------------------------------------

    -- local dtype_bar_width = w * 1.3 + side_bar_width
    -- -- local dtype_bar_width = self.options.width * 0.8 + side_bar_width

    -- self.dtype_bar:SetSize(dtype_bar_width, up_bar_height)
    -- self.dtype_bar:SetPosition(-self.options.width / 2 - side_bar_width + dtype_bar_width / 2,
    --     self.options.height / 2 + up_bar_height / 2)
    -- self.dtype_bar:SetScale(1, -1)

    local upright_width = 50
    self.upright_corner:SetSize(upright_width, up_bar_height)
    self.upright_corner:SetPosition(self.options.width / 2 + side_bar_width - upright_width / 2,
        self.options.height / 2 + up_bar_height / 2)
end

function BlytheSkillList:FullfilGrids()
    local num_visible_rows = #self.options.skills_data

    self.items = {}
    for _, v in pairs(self.options.skills_data) do
        table.insert(self.items, self:CreateSkillListItem(v))
    end

    self.grid:FillGrid(1, 0, self.options.grid_height / num_visible_rows, self.items)
    self.grid:SetPosition(0, (self.options.grid_height - self.options.grid_height / num_visible_rows) / 2)
end

function BlytheSkillList:CreateSkillListItem(data)
    local num_visible_rows = #self.options.skills_data
    local block_wh = self.options.grid_height / num_visible_rows - 15

    local item_options = {
        width = self.options.width,
        height = self.options.grid_height / num_visible_rows,
        block_wh = block_wh,
        space_width = self.options.space_width,
    }
    local item = self:AddChild(BlytheSkillListItem(self.owner, item_options))

    item.skill_name = data.name

    if self.owner.replica.blythe_skiller and self.owner.replica.blythe_skiller:IsLearned(data.name) then
        local text = STRINGS.STARILIAD_UI.SKILL_DETAIL[data.name:upper()].NAME
        item:SetText(text)
    else
        item:SetText(nil)
    end

    return item
end

function BlytheSkillList:GetItemBySkillName(skill_name)
    for _, v in pairs(self.items) do
        if v.skill_name == skill_name then
            return v
        end
    end
end

-- function BlytheSkillList:PlayLearningAnim(skill_name)
--     if self.learning_item then
--         self:EndLearningAnim(true)
--     end

--     for _, v in pairs(self.items) do
--         if v.skill_name == skill_name then
--             self.learning_item = v
--             break
--         end
--     end

--     if not self.learning_item then
--         print("No skill item:", skill_name)
--         return
--     end

--     self.learning_item:PlayLearningAnim()
-- end

-- function BlytheSkillList:EndLearningAnim(interrupt)
--     if self.learning_item then
--         self.learning_item:EndLearningAnim(interrupt)
--     end
--     self.learning_item = nil
-- end

return BlytheSkillList
