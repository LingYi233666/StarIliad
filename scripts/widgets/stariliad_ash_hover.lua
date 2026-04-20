local Widget = require "widgets/widget"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"


local StarIliadAshHover = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadAshHover")


    self.ash_anim = self:AddChild(UIAnim())
end)




return StarIliadAshHover
