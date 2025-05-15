local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local BlytheSkillActiveFX = require "widgets/blythe_skill_active_fx"
local StarIliadShinningBlock = require "widgets/stariliad_shinning_block"

local BlytheSkillListItem = Class(Widget, function(self, owner, options)
    Widget._ctor(self, "BlytheSkillListItem")


    self.owner = owner
    self.options = options
    -- self.options = {
    --     width = width,
    --     height = height,
    --     block_wh = block_wh,
    --     space_width = space_width,
    -- }

    self.text_button = self:AddChild(TextButton())
    self.text_button:SetFont(TITLEFONT)
    self.text_button:SetTextSize(34)
    self.text_button:SetTextFocusColour({ 1, 1, 1, 1 })

    -- self.block = self.text_button:AddChild(Image("images/global.xml", "square.tex"))
    self.block = self.text_button:AddChild(StarIliadShinningBlock({
        { 255 / 255, 200 / 255, 0 / 255,  1 },
        { 255 / 255, 10 / 255,  10 / 255, 1 },
    }, 0.3))
    self.block:SetSize(self.options.block_wh, self.options.block_wh)
    -- block:SetPosition(-self.options.grid_width / 2 + block_wh / 2, 0)
end)


function BlytheSkillListItem:SetText(text)
    local w, h = 0, 0

    self.block:StopShinning()

    if text and type(text) == "string" then
        -- text:SetString(data.name)
        -- text:SetColour(unpack(UICOLOURS.GOLD))
        -- text:SetColour(unpack(UICOLOURS.WHITE))

        self.text_button:SetText(text)
        self.text_button:SetTextColour(unpack(UICOLOURS.GOLD))
        self.text_button:SetClickable(true)

        self.block:SetTint(255 / 255, 200 / 255, 0, 1)

        w, h = self.text_button.text:GetRegionSize()
    else
        -- text:SetString("")
        -- text:SetColour(unpack(UICOLOURS.GREY))
        self.text_button:SetText("")
        self.text_button:SetColour(unpack(UICOLOURS.GREY))
        self.text_button:SetClickable(false)

        self.block:SetTint(unpack(UICOLOURS.GREY))
    end

    self.text_button:SetPosition(-self.options.width / 2 + w / 2 + self.options.block_wh + self.options.space_width * 2,
        0)

    self.block:SetPosition(-w / 2 - self.options.block_wh / 2 - self.options.space_width, 0)
end

function BlytheSkillListItem:RefreshText()
    local text = self.text_button:GetText()
    self:SetText(text)
end

function BlytheSkillListItem:SetOnClick(fn)
    self.text_button:SetOnClick(fn)
end

-- function BlytheSkillListItem:PlayLearningAnim()
--     self.text_button:SetColour(unpack(UICOLOURS.GREY))
--     self.text_button:SetClickable(false)
--     self.block:SetTint(255 / 255, 70 / 255, 52 / 255, 1)

--     self.active_fx = self.block:AddChild(BlytheSkillActiveFX())
--     self.active_fx:SetPosition(0, 15)
--     self.active_fx.inst:ListenForEvent("animover", function()
--         self:EndLearningAnim()
--     end)

--     TheFocalPoint.SoundEmitter:PlaySound("wilson_rework/ui/skill_mastered")
-- end

-- function BlytheSkillListItem:EndLearningAnim(interrupt)
--     self:RefreshText()
--     if self.active_fx then
--         self.active_fx:Kill()
--         self.active_fx = nil
--     end
-- end

return BlytheSkillListItem
