local Widget = require "widgets/widget"
local Image = require "widgets/image"


local BlytheGridBG = Class(Widget, function(self, options)
    Widget._ctor(self, "BlytheGridBG")

    self.options = options
    self.bars = {}


    -- options = {
    --     width = 10,
    --     height = 10,
    --     num_steps_hor = 10,
    --     num_steps_vert = 10,

    --     up_down_bar_width = 2,
    --     up_down_bar_color = { 1, 1, 1, 1 },
    --     left_right_bar_height = 2,
    --     left_right_bar_color = { 1, 1, 1, 1 },
    --     ignore_edge = true,
    -- }

    local step_hor = options.width / options.num_steps_hor
    local step_vert = options.height / options.num_steps_vert


    -- for j = 0, step_vert do
    --     for i = 0, step_hor do

    --     end
    -- end



    -- Draw left-right line
    for i = 0, options.num_steps_vert do
        if i == 0 or i == options.num_steps_vert and options.ignore_edge then

        else
            local x = 0
            local y = step_vert * i - options.height / 2

            local bar = self:AddChild(Image("images/global.xml", "square.tex"))
            bar:SetPosition(x, y)
            bar:SetSize(options.width, options.left_right_bar_height)
            bar:SetTint(unpack(options.left_right_bar_color))
            table.insert(self.bars, bar)
        end
    end

    -- Draw up-down line
    for i = 0, options.num_steps_hor do
        if i == 0 or i == options.num_steps_hor and options.ignore_edge then

        else
            local x = step_hor * i - options.width / 2
            local y = 0

            local bar = self:AddChild(Image("images/global.xml", "square.tex"))
            bar:SetPosition(x, y)
            bar:SetSize(options.up_down_bar_width, options.height)
            bar:SetTint(unpack(options.up_down_bar_color))
            table.insert(self.bars, bar)
        end
    end
end)

return BlytheGridBG
