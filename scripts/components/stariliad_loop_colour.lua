local StarIliadLoopColour = Class(function(self, inst)
    self.inst = inst

    self.mult_colour_mem = {
        head_index = 1,
        ts = 0,
        duration = 1.0,
        colours = {
            -- percent, r, g, b, a
            -- { 0.0, 0 / 255,   0 / 255,   0 / 255, 1.0 },
            -- { 0.3, 255 / 255, 0 / 255,   0 / 255, 1.0 },
            -- { 0.5, 0 / 255,   255 / 255, 0 / 255, 1.0 },
            -- { 1.0, 0 / 255,   0 / 255,   0 / 255, 1.0 },
        },
    }
    self.ignore_mult_colour_alpha = false

    self.add_colour_mem = {
        head_index = 1,
        ts = 0,
        duration = 1.0,
        colours = {

        },
    }
end)

function StarIliadLoopColour:SetMultColourList(colours)
    self.mult_colour_mem.colours = colours
end

function StarIliadLoopColour:SetMultColourDuration(duration)
    self.mult_colour_mem.duration = duration
end

function StarIliadLoopColour:SetAddColourList(colours)
    self.add_colour_mem.colours = colours
end

function StarIliadLoopColour:SetAddColourDuration(duration)
    self.add_colour_mem.duration = duration
end

function StarIliadLoopColour:Enable(enable)
    if enable then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
    end
end

function StarIliadLoopColour:UpdatePart(tab, dt)
    local circled = false

    tab.ts = tab.ts + dt
    if tab.ts >= tab.duration then
        tab.head_index = 1
        while tab.ts > tab.duration do
            tab.ts = tab.ts - tab.duration
        end
    end

    local percent = tab.ts / tab.duration

    while tab.head_index < #tab.colours - 1 do
        if tab.colours[tab.head_index][1] <= percent and percent < tab.colours[tab.head_index + 1][1] then
            break
        end
    end

    local p1, r1, g1, b1, a1 = unpack(tab.colours[tab.head_index])
    local p2, r2, g2, b2, a2 = unpack(tab.colours[tab.head_index + 1])
    local factor = (percent - p1) / (p2 - p1)

    local r = r1 + (r2 - r1) * factor
    local g = g1 + (g2 - g1) * factor
    local b = b1 + (b2 - b1) * factor
    local a = a1 + (a2 - a1) * factor

    return r, g, b, a, circled
end

function StarIliadLoopColour:OnUpdate(dt)
    if #(self.mult_colour_mem.colours) > 0 then
        local r, g, b, a, circled = self:OnUpdatePart(self.mult_colour_mem, dt)

        if self.ignore_mult_colour_alpha then
            local cur_r, cur_g, cur_b, cur_a = self.inst.AnimState:GetMultColour()
            self.inst.AnimState:SetMultColour(r, g, b, cur_a)
        else
            self.inst.AnimState:SetMultColour(r, g, b, a)
        end

        if circled then
            self.inst:PushEvent("stariliad_loop_colour_mult_circled")
        end
    end

    if #(self.add_colour_mem.colours) > 0 then
        local r, g, b, a, circled = self:OnUpdatePart(self.add_colour_mem, dt)
        self.inst.AnimState:SetAddColour(r, g, b, a)

        if circled then
            self.inst:PushEvent("stariliad_loop_colour_add_circled")
        end
    end
    end
end

return StarIliadLoopColour
