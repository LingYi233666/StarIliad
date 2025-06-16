local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"

local TIPS_DEFINE = {

}


local StarIliadTip = Class(Widget, function(self, owner)
    Widget._ctor(self, "StarIliadTip")

    self.owner = owner
end)

return StarIliadTip
