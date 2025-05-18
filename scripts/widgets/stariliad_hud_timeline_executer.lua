local Widget = require "widgets/widget"

local StarIliadHUDTimelineExecuter = Class(Widget, function(self, master)
    Widget._ctor(self, "StarIliadHUDTimelineExecuter")

    self.master = master

    self.onenter = nil
    self.onupdate = nil
    self.onexit = nil
    self.ontimeout = nil

    self.duration = nil
end)

function StarIliadHUDTimelineExecuter:SetOnEnterFn(fn)
    self.onenter = fn
end

function StarIliadHUDTimelineExecuter:SetOnUpdateFn(fn)
    self.onupdate = fn
end

function StarIliadHUDTimelineExecuter:SetOnExitFn(fn)
    self.onexit = fn
end

function StarIliadHUDTimelineExecuter:SetOnTimeoutFn(fn)
    self.ontimeout = fn
end

function StarIliadHUDTimelineExecuter:SetTimeout(duration, fn)
    self.duration = duration
end

function StarIliadHUDTimelineExecuter:SetTimeline(timeline)
    self.timeline = timeline or {}
    table.sort(self.timeline, function(a, b)
        return a.time < b.time
    end)
end

function StarIliadHUDTimelineExecuter:SetFromTable(tab)
    self:SetOnEnterFn(tab.onenter)
    self:SetOnUpdateFn(tab.onupdate)
    self:SetOnExitFn(tab.onexit)
    self:SetOnTimeoutFn(tab.ontimeout)
    self:SetTimeout(tab.duration)
    self:SetTimeline(tab.timeline)
end

function StarIliadHUDTimelineExecuter:Run(mem_override)
    self.mem = mem_override or {}
    self.start_time = GetStaticTime()
    self.last_update_time = self.start_time
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

function StarIliadHUDTimelineExecuter:OnUpdate()
    local cur_time = GetStaticTime()
    local time_elapse = cur_time - self.start_time


    while self.index <= #self.timeline do
        if time_elapse < self.timeline[self.index].time then
            break
        end

        if self.timeline[self.index].fn then
            self.timeline[self.index].fn(self.master, self.mem)
        end

        self.index = self.index + 1
    end

    if self.onupdate then
        self.onupdate(self.master, self.mem, cur_time - self.last_update_time)
    end

    if self.duration then
        if time_elapse >= self.duration then
            if self.ontimeout then
                self.ontimeout(self.master, self.mem)
            end
            self:Cancel()
        end
    else
        -- if self.index > #self.timeline then
        --     self:Cancel()
        -- end
    end

    self.last_update_time = cur_time
end

return StarIliadHUDTimelineExecuter
