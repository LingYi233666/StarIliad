local Widget = require "widgets/widget"
local Image = require "widgets/image"

-- self.bg = self.root:AddChild(Image("images/global.xml", "square.tex"))
-- self.bg:SetSize(self.bg_width, self.bg_height)
-- self.bg:SetTint(0 / 255, 37 / 255, 65 / 255, 1)

local StarIliadPolyLines = Class(Widget, function(self, options)
    Widget._ctor(self, "StarIliadPolyLines")


    -- options = {
    --     points = {
    --         Vector3(0, 0),
    --         Vector3(100, 0),
    --         Vector3(100, 100),
    --     },

    --     is_closed = false,

    --     color = { 255 / 255, 255 / 255, 255 / 255, 1 },

    --     thickness = 2,
    -- }

    self.options = options

    self.lines = {}
    self.circles = {}

    self:Draw()
end)

function StarIliadPolyLines:Draw()
    local num_points = #(self.options.points)

    for i = 1, num_points do
        table.insert(self.circles, self:DrawCircle(self.options.points[i], self.options.thickness, self.options.color))
    end

    for i = 1, num_points do
        if not self.options.is_closed and i == num_points then
            break
        end

        local start_pos = self.options.points[i]
        local end_pos
        if i == num_points then
            end_pos = self.options.points[1]
        else
            end_pos = self.options.points[i + 1]
        end

        table.insert(self.lines, self:DrawLine(start_pos, end_pos))
    end
end

function StarIliadPolyLines:DrawCircle(pos, rad, color)
    local circle = self:AddChild(Image("images/ui/stariliad_circle.xml", "stariliad_circle.tex"))
    circle:SetSize(rad, rad)
    circle:SetTint(unpack(color))
    circle:SetPosition(pos)

    return circle
end

function StarIliadPolyLines:DrawLine(start_pos, end_pos)
    local length = (start_pos - end_pos):Length()
    local forward = (end_pos - start_pos):GetNormalized()
    -- local angle = math.atan2(forward.y, forward.x)

    local line = self:AddChild(Image("images/ui/stariliad_square.xml", "stariliad_square.tex"))
    line:SetSize(length, self.options.thickness)
    line:SetTint(unpack(self.options.color))
    line:SetPosition((start_pos + end_pos) / 2)
    -- line:SetRotation(angle * RADIANS)
    line:SetRotation(-math.atan2(forward.y, forward.x) * RADIANS)

    return line
end

return StarIliadPolyLines
