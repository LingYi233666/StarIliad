local Widget = require "widgets/widget"
local Image = require "widgets/image"

local StarIliadShinningBlock = Class(Image, function(self, colors, seg_time)
    Image._ctor(self, "images/global.xml", "square.tex")

    self.colors = colors
    self.seg_time = seg_time or 1
end)

function StarIliadShinningBlock:StartShinning()
    self.update_time = GetStaticTime()
    self.index = 1

    self:StartUpdating()
end

function StarIliadShinningBlock:StopShinning()
    self:StopUpdating()
end

function StarIliadShinningBlock:InterColor(color1, color2, percent)
    local r1, g1, b1, a1 = unpack(color1)
    local r2, g2, b2, a2 = unpack(color2)
    local dr, dg, db, da = r2 - r1, g2 - g1, b2 - b1, a2 - a1

    return r1 + dr * percent, g1 + dg * percent, b1 + db * percent, a1 + da * percent
end

function StarIliadShinningBlock:OnUpdate()
    -- local time_elapse = GetStaticTime() - self.start_time
    -- local p = time_elapse / self.seg_time + 1
    -- if p >= #self.colors + 1 then
    --     p = p - #self.colors
    -- end

    -- local index_i = math.floor(p)
    -- local percent = p - index_i
    -- local index_j = index_i + 1
    -- if index_j > #self.colors then
    --     index_j = 1
    -- end

    -- local r, g, b, a = self:InterColor(self.colors[index_i], self.colors[index_j], percent)

    -- self:SetTint(r, g, b, a)

    local cur_time = GetStaticTime()
    local time_elapse = cur_time - self.update_time
    self.update_time = cur_time


    self.index = self.index + time_elapse / self.seg_time

    if self.index >= #self.colors + 1 then
        self.index = self.index - #self.colors
    end

    local index_i = math.floor(self.index)
    local percent = self.index - index_i
    local index_j = index_i + 1
    if index_j > #self.colors then
        index_j = 1
    end

    local r, g, b, a = self:InterColor(self.colors[index_i], self.colors[index_j], percent)

    self:SetTint(r, g, b, a)
end

return StarIliadShinningBlock
