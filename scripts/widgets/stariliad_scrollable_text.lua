local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"


local StarIliadScrollableText = Class(Widget, function(self, options)
    Widget._ctor(self, "StarIliadScrollableText")


    self.options = options
    self.options.bar_padding = self.options.bar_padding or 10
    self.options.scroll_per_click = self.options.scroll_per_click or 20
    -- options = {
    --     text_font = NUMBERFONT,
    --     text_size = 34,
    --     text_color = UICOLOURS.GOLD,
    --     text_width = 600,
    --     visible_height = 200,
    --     bar_padding = 10,
    --     scroll_per_click = 10,
    -- }

    self.blank = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self.blank:SetSize(self.options.text_width + self.options.bar_padding, self.options.visible_height)
    self.blank:SetPosition(self.options.bar_padding / 2, 0)

    self.text = self:AddChild(Text(self.options.text_font, self.options.text_size))
    self.text:SetVAlign(ANCHOR_TOP)
    self.text:SetHAlign(ANCHOR_LEFT)
    if self.options.text_color then
        self.text:SetColour(self.options.text_color)
    end



    self:BuildScrollBar()
end)

function StarIliadScrollableText:SetString(str)
    self.text:SetMultilineTruncatedString(str, 99999, self.options.text_width)
    -- self:BuildScrollBar()

    -- Update scroll bar
    local _, text_h = self.text:GetRegionSize()
    local line_height = self:GetLineHeight()
    local old_x = self.scroll_bar_container:GetPosition().x
    self.scroll_bar_container:SetPosition(old_x, (text_h - line_height) / 2)
    if text_h <= self.options.visible_height then
        self.scroll_bar_container:Hide()
    else
        self.scroll_bar_container:Show()
    end

    self:RefreshView()
end

function StarIliadScrollableText:SetTextScissor(start_y, height)
    local w, h = self.text:GetRegionSize()

    self.text:SetScissor(-w / 2 - 1, start_y, w + 1, height)
end

function StarIliadScrollableText:GetLineHeight()
    return self.options.visible_height
end

function StarIliadScrollableText:GetMarkerRangeY()
    local line_height = self:GetLineHeight()
    local min_y = -line_height / 2
    local max_y = line_height / 2

    return min_y, max_y
end

-- function StarIliadScrollableText:AdjustMarkerPosY(y)
--     local min_y, max_y = self:GetMarkerRangeY()
--     return math.clamp(y, min_y, max_y)
-- end

-- function StarIliadScrollableText:GetMarkerPercent()
--     local y = self.position_marker:GetWorldPosition().y
--     local min_y, max_y = self:GetMarkerRangeY()

--     return Remap(y, min_y, max_y, 1, 0)
-- end

function StarIliadScrollableText:SetMarkerY(y)
    local min_y, max_y = self:GetMarkerRangeY()
    local new_y = math.clamp(y, min_y, max_y)
    local old_y = self.position_marker:GetPosition().y
    self.position_marker:SetPosition(0, new_y)
    self:RefreshView()

    return math.abs(old_y - new_y) > 1e-3
end

function StarIliadScrollableText:DoDeltaMarkerY(delta)
    local old_y = self.position_marker:GetPosition().y
    return self:SetMarkerY(old_y + delta)
end

function StarIliadScrollableText:MouseUpdateMarkerY()
    local min_y, max_y = self:GetMarkerRangeY()
    self.position_marker:SetPosition(0, min_y)
    local min_world_y = self.position_marker:GetWorldPosition().y
    self.position_marker:SetPosition(0, max_y)
    local max_world_y = self.position_marker:GetWorldPosition().y

    local target_world_y = math.clamp(TheFrontEnd.lasty, min_world_y, max_world_y)
    local target_world_percent = Remap(target_world_y, min_world_y, max_world_y, 0, 1)

    local target_y = min_y + (max_y - min_y) * target_world_percent

    self:SetMarkerY(target_y)
end

function StarIliadScrollableText:DoDragScroll()
    self.position_marker.o_pos = nil
    local marker_pos = self.position_marker:GetWorldPosition()
    if math.abs(TheFrontEnd.lastx - marker_pos.x) <= 150 then
        self:MouseUpdateMarkerY()
    end
end

function StarIliadScrollableText:RefreshView()
    local y = self.position_marker:GetPosition().y
    local min_y, max_y = self:GetMarkerRangeY()

    local _, text_h = self.text:GetRegionSize()
    local start_y1 = text_h / 2 - self.options.visible_height
    local start_y2 = -text_h / 2

    local cur_start_y = Remap(y, min_y, max_y, start_y2, start_y1)
    self:SetTextScissor(cur_start_y, self.options.visible_height)

    local _, text_h = self.text:GetRegionSize()
    local text_y = Remap(y, min_y, max_y, text_h - self.options.visible_height, 0)
    self.text:SetPosition(0, text_y)

    TheFrontEnd:DoHoverFocusUpdate(true)
end

function StarIliadScrollableText:BuildScrollBar()
    if self.scroll_bar_container then
        self.scroll_bar_container:Kill()
    end

    local _, text_h = self.text:GetRegionSize()

    local line_height = self:GetLineHeight()

    self.scroll_bar_container = self:AddChild(Widget("scroll_bar_container"))
    self.scroll_bar_container:SetPosition(self.options.text_width / 2 + self.options.bar_padding,
        (text_h - line_height) / 2)
    if text_h <= self.options.visible_height then
        self.scroll_bar_container:Hide()
    else
        self.scroll_bar_container:Show()
    end

    self.scroll_bar_line = self.scroll_bar_container:AddChild(Image("images/global_redux.xml", "scrollbar_bar.tex"))
    self.scroll_bar_line:SetSize(10, line_height)

    --self.scroll_bar is used just for clicking on it
    self.scroll_bar = self.scroll_bar_container:AddChild(ImageButton("images/ui.xml", "1percent_clickbox.tex",
        "1percent_clickbox.tex", "1percent_clickbox.tex", nil, nil, { 1, 1 }, { 0, 0 }))
    self.scroll_bar.image:ScaleToSize(18, line_height)
    self.scroll_bar.image:SetTint(1, 1, 1, 0)
    self.scroll_bar.scale_on_focus = false
    self.scroll_bar.move_on_click = false
    self.scroll_bar:SetOnClick(function()
        self:MouseUpdateMarkerY()
    end)

    self.position_marker = self.scroll_bar_container:AddChild(ImageButton("images/global_redux.xml",
        "scrollbar_handle.tex"))
    self.position_marker.scale_on_focus = false
    self.position_marker.move_on_click = false
    self.position_marker.show_stuff = true
    self.position_marker:SetPosition(0, line_height / 2)
    self.position_marker:SetScale(0.3, 0.3, 1)
    self.position_marker:SetOnDown(function()
        TheFrontEnd:LockFocus(true)
    end)
    self.position_marker:SetWhileDown(function()
        self:DoDragScroll()
    end)
    self.position_marker:SetOnClick(function()
        TheFrontEnd:LockFocus(false)
        self:RefreshView() --refresh again after we've been moved back to the "up-click" position in Button:OnControl
    end)
end

function StarIliadScrollableText:OnControl(control, down)
    if StarIliadScrollableText._base.OnControl(self, control, down) then return true end

    if down and self.focus and self.scroll_bar:IsVisible() then
        if control == CONTROL_SCROLLBACK then
            local scroll_amt = self.options.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            if self:DoDeltaMarkerY(scroll_amt) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        elseif control == CONTROL_SCROLLFWD then
            local scroll_amt = -self.options.scroll_per_click
            if TheInput:ControllerAttached() then
                scroll_amt = scroll_amt / 2
            end
            if self:DoDeltaMarkerY(scroll_amt) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            end
            return true
        end
    end
end

return StarIliadScrollableText
