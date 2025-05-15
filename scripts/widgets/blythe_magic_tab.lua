local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local BlytheMagicTab = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlytheMagicTab")

    self.owner = owner

    self.test_text = self:AddChild(Text(TITLEFONT, 34, "!!! TEST MAGIC TEXT !!!"))
    self.test_text:SetColour(UICOLOURS.GOLD_SELECTED)
    -- self.test_text:SetPosition(295, 200)
end)

return BlytheMagicTab
