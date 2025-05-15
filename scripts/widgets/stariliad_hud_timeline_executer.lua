local Widget = require "widgets/widget"

local StarIliadHUDTimelineExecuter = Class(Widget, function(self, master)
    Widget._ctor(self, "StarIliadHUDTimelineExecuter")

    self.master = master
end)

function StarIliadHUDTimelineExecuter:SetTimeline(timeline)
    self.timeline = timeline or {}
    table.sort(self.timeline, function(a, b)
        return a.time < b.time
    end)
end

function StarIliadHUDTimelineExecuter:SetOnEnterFn(onenter)
    self.onenter = onenter
end

function StarIliadHUDTimelineExecuter:SetOnExitFn(onexit)
    self.onexit = onexit
end

function StarIliadHUDTimelineExecuter:Run(mem_override)
    self.mem = mem_override or {}
    self.start_time = GetStaticTime()
    self.index = 1

    self:StartUpdating()

    if self.onenter then
        self.onenter(self.master, self.mem)
    end
end

function StarIliadHUDTimelineExecuter:Cancel()
    self:StopUpdating()

    if self.onexit then
        self.onexit(self.master, self.mem)
    end

    self:Kill()
end

function StarIliadHUDTimelineExecuter:OnUpdate(unused_dt)
    local time_elapse = GetStaticTime() - self.start_time

    while self.index <= #self.timeline do
        if time_elapse < self.timeline[self.index].time then
            break
        end

        if self.timeline[self.index].fn then
            self.timeline[self.index].fn(self.master, self.mem)
        end

        self.index = self.index + 1
    end

    if self.index > #self.timeline then
        self:Cancel()
    end
end

return StarIliadHUDTimelineExecuter
