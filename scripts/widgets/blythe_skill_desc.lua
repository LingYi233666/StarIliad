local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local StarIliadHUDTimelineExecuter = require "widgets/stariliad_hud_timeline_executer"

local BlytheSkillDesc = Class(Widget, function(self, options)
    Widget._ctor(self, "BlytheSkillDesc")


    self.options = options


    self.bg = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetSize(self.options.width, self.options.height)
    self.bg:SetTint(0, 0, 0, 1)

    self.text = self:AddChild(Text(NUMBERFONT, 30))
    self.text:SetVAlign(ANCHOR_TOP)
    self.text:SetHAlign(ANCHOR_LEFT)

    ------------------------------------------

    local side_bar_width = 3

    local down_bar_width = self.options.width + side_bar_width * 2
    local down_bar_height = 3

    local up_bar_width = self.options.width + side_bar_width * 2
    local up_bar_height = 3

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
end)


function BlytheSkillDesc:SetText(text)
    if text and type(text) == "string" and #text > 0 then
        self.text:SetMultilineTruncatedString(text, 999, self.options.width - self.options.space_width * 2)

        local w, h = self.text:GetRegionSize()
        self.text:SetPosition(-self.options.width / 2 + w / 2 + self.options.space_width,
            self.options.height / 2 - h / 2 - self.options.space_height)
        self.text:Show()
    else
        self.text:SetString("")
        self.text:Hide()
    end
end

-----------------------------------------------------------------

local SG_slide_show_text = {
    onenter  = function(self, mem)
        mem.length = 0
        mem.max_length = StarIliadString.StrLen(mem.sliding_text)

        self.te:SetTimeout(mem.max_length / mem.speed)
    end,

    onupdate = function(self, mem, dt)
        mem.length = mem.length + dt * mem.speed

        local l = math.floor(mem.length)
        local text = StarIliadString.Strip(mem.sliding_text, 1, l)
        self:SetText(text)
    end,

    onexit   = function(self, mem)
        -- print("BlytheSkillDesc te exit")

        self:SetText(mem.sliding_text)
        self.te = nil
    end,
}

function BlytheSkillDesc:SlideShowText(sliding_text)
    self:CancelSlideShowText()

    if #sliding_text <= 0 then
        return
    end

    self.te = self:AddChild(StarIliadHUDTimelineExecuter(self))
    self.te:SetFromTable(SG_slide_show_text)
    self.te:Run({
        sliding_text = sliding_text,
        speed = 20,
    })

    self:SetText(nil)
end

function BlytheSkillDesc:CancelSlideShowText()
    if self.te then
        self.te:Cancel()
    end
    self.te = nil
end

return BlytheSkillDesc
