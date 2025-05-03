local Widget = require "widgets/widget"
local Image = require "widgets/image"

local StarIliadUsurperShotArrows = Class(Widget, function(self, use_sound)
    Widget._ctor(self, "StarIliadUsurperShotArrows")

    self.arrows = {}
    self.progress = 0
    self.speed = 5
    self.use_sound = use_sound
end)

function StarIliadUsurperShotArrows:ClearArrows()
    self:StopUpdating()

    for _, v in pairs(self.arrows) do
        v:Kill()
    end
    self.arrows = {}
    self.progress = 0
end

function StarIliadUsurperShotArrows:Init(pos1, pos2)
    self:ClearArrows()

    local delta_dist = 50
    local delta_vec = pos2 - pos1
    local delta_vec_norm = delta_vec:GetNormalized()
    local angle = math.atan2(-delta_vec.y, delta_vec.x) * RADIANS
    local num_arrows = math.floor(delta_vec:Length() / delta_dist)


    for i = 0, num_arrows do
        local image = self:AddChild(Image("images/ui.xml", "arrow_right_over.tex"))

        -- image:SetScale(0.6)
        image:SetSize(50, 50)
        image:SetScaleMode(SCALEMODE_PROPORTIONAL)
        image:SetRotation(angle)
        image:SetPosition(pos1 + delta_vec_norm * delta_dist * i)
        image:Hide()

        table.insert(self.arrows, image)
    end

    -- print("num_arrows:", #(self.arrows))

    self.speed = math.max(5, num_arrows / 1)

    self:StartUpdating()
end

function StarIliadUsurperShotArrows:OnUpdate()
    if self.finish_flag then
        self:ClearArrows()
        return
    end

    -- local num_arrows = #(self.arrows)
    -- local last_shown_arrows = 0
    -- local will_shown_arrows = math.floor(num_arrows * math.min(1, self.progress))

    -- for _, v in pairs(self.arrows) do
    --     if v.shown then
    --         last_shown_arrows = last_shown_arrows + 1
    --     end
    -- end

    -- for i = 1, will_shown_arrows do
    --     self.arrows[i]:Show()
    -- end

    -- if self.use_sound and will_shown_arrows > last_shown_arrows then
    --     TheFocalPoint.SoundEmitter:PlaySound("stariliad_sfx/hud/swap_click")
    -- end

    -- if self.progress >= 1 + (1.0 / num_arrows) * 2 then
    --     self.finish_flag = true
    -- end

    -- self.progress = self.progress + self.speed * FRAMES

    local num_arrows = #(self.arrows)

    local old_cnt = math.min(math.floor(self.progress), num_arrows)
    self.progress = self.progress + self.speed * FRAMES
    local new_cnt = math.min(math.floor(self.progress), num_arrows)

    for i = 1, new_cnt do
        self.arrows[i]:Show()
    end

    if self.progress >= num_arrows + 1 then
        self.finish_flag = true
    end

    if self.use_sound and new_cnt > old_cnt then
        TheFocalPoint.SoundEmitter:PlaySound("stariliad_sfx/hud/swap_click")
    end
end

return StarIliadUsurperShotArrows
