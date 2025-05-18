local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local StarIliadMainMenu = require "screens/stariliad_main_menu"
local BlytheSkillDesc = require "widgets/blythe_skill_desc"

local BlytheItemAcquired = Class(Screen,
    function(self, owner, title_str, description_str, sound, duration, skill_names, orphan_widgets)
        Screen._ctor(self, "BlytheItemAcquired")

        -- self.grid = self:AddChild(Grid())

        -- FillGrid(num_columns, coffset, roffset, items)
        -- self.grid:FillGrid(1, 0, self.options.grid_height / num_visible_rows, self.items)
        -- self.grid:SetPosition(0, (self.options.grid_height - self.options.grid_height / num_visible_rows) / 2)

        self.owner          = owner
        self.duration       = duration or 6
        self.duration_open  = 0.6
        self.duration_close = 0.6
        self.skill_names    = skill_names


        self.root = self:AddChild(TEMPLATES.ScreenRoot("BlytheItemAcquired"))

        -- self.box  = self.root:AddChild(Image("images/global.xml", "square.tex"))
        -- self.box:SetSize(530, 125)
        -- self.box:SetTint(unpack(UICOLOURS.BLACK))

        self.box = self.root:AddChild(BlytheSkillDesc({
            width = 530,
            height = 125,
            space_width = 0,
            space_height = 0,
        }))
        -- self.box.bg:SetTint(unpack(UICOLOURS.BLACK))

        self.title = self.box:AddChild(Text(NUMBERFONT, 37))
        self.title:SetString(title_str)
        -- self.title:SetColour(UICOLOURS.GOLD)
        -- self.title:SetPosition(0, 10)

        self.description = self.box:AddChild(Text(NUMBERFONT, 34))
        self.description:SetString(description_str)
        -- self.description:SetColour(UICOLOURS.GOLD)

        if title_str and description_str then
            self.title:SetPosition(0, 25)
            self.description:SetPosition(0, -25)
        end

        if sound then
            TheFrontEnd:GetSound():PlaySound(sound)
        end

        SetAutopaused(true)

        self:ScaleIn()

        self.inst:DoStaticTaskInTime(self.duration, function()
            self:ScaleOut()
        end)
    end)

function BlytheItemAcquired:OnDestroy()
    SetAutopaused(false)
    BlytheItemAcquired._base.OnDestroy(self)
end

function BlytheItemAcquired:ScaleIn()
    self:StopUpdating()
    self.box:SetScale(0.5, 0.05)
    self.start_time = GetStaticTime()
    self.is_opening = true
    self.is_closing = false
    self:StartUpdating()
end

function BlytheItemAcquired:ScaleOut()
    self:StopUpdating()
    self.start_time = GetStaticTime()
    self.is_opening = false
    self.is_closing = true
    self:StartUpdating()
end

function BlytheItemAcquired:OnUpdateCommon(sx_start, sx_end, sy_start, sy_end, duration)
    local time_elapse = math.min(GetStaticTime() - self.start_time, duration)

    local sx = easing.outCubic(time_elapse, sx_start, sx_end - sx_start, duration)
    local sy = easing.outCubic(time_elapse, sy_start, sy_end - sy_start, duration)

    self.box:SetScale(sx, sy)

    return time_elapse >= duration
end

function BlytheItemAcquired:OnUpdate()
    if self.is_opening then
        local sx_start = 0.5
        local sx_end = 1
        local sy_start = 0.01
        local sy_end = 1
        if self:OnUpdateCommon(sx_start, sx_end, sy_start, sy_end, self.duration_open) then
            self.is_opening = false
            self:StopUpdating()
        end
    elseif self.is_closing then
        local sx_start = 1
        local sx_end = 0.5
        local sy_start = 1
        local sy_end = 0.01
        if self:OnUpdateCommon(sx_start, sx_end, sy_start, sy_end, self.duration_close) then
            self.is_closing = false

            if self.skill_names and #(self.skill_names) > 0 then
                local main_menu = StarIliadMainMenu(self.owner)
                main_menu.tab_screens.powersuit_display:MakeItemsGray(self.skill_names)

                main_menu:SlideIn(1, function()
                    main_menu:PlayLearningAnim(self.skill_names)
                end)
                TheFrontEnd:PushScreen(main_menu)
            end
            TheFrontEnd:PopScreen(self)
        end
    end
end

-- function BlytheItemAcquired:OnUpdate()
--     local time_elapse = math.min(GetStaticTime() - self.start_time, self.duration_close)
--     -- self.duration_close

--     local min_scale_x = 0.5
--     local max_scale_x = 1
--     local min_scale_y = 0.05
--     local max_scale_y = 1

--     local sx = easing.outCubic(time_elapse, min_scale_x, max_scale_x - min_scale_x, self.duration_close)
--     local sy = easing.outCubic(time_elapse, min_scale_y, max_scale_y - min_scale_y, self.duration_close)

--     self.box:SetScale(sx, sy)

--     if time_elapse >= self.duration_close then
--         -- if self.close_callback then
--         --     self.close_callback()
--         -- end
--         if self.skill_names and #(self.skill_names) > 0 then
--             local main_menu = StarIliadMainMenu(self.owner)
--             main_menu:SlideIn(1, function()
--                 main_menu:PlayLearningAnim(self.skill_names)
--             end)
--             TheFrontEnd:PushScreen(main_menu)
--         end
--         TheFrontEnd:PopScreen(self)
--     end
-- end

return BlytheItemAcquired
