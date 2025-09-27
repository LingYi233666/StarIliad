local Widget = require "widgets/widget"
local Text = require "widgets/text"

local StariliadShakingText = Class(Widget, function(self, font, size, text, colour)
    Widget._ctor(self, "StariliadShakingText")

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.font = font
    self.size = size
    self.colour = colour or { 1, 1, 1, 1 }

    self.words = {}
    self.words_pos = {}

    if text then
        self:SetString(text)
    end

    self:StartUpdating()
end)

local function GetWidth(char)

end

function StariliadShakingText:SetString(text)
    self.text = text

    for _, v in pairs(self.words) do
        v:Kill()
    end
    self.words = {}

    local split_texts = StarIliadString.Split(text)
    local sum_width = 0
    local width_factor = 0.85

    for _, v in pairs(split_texts) do
        local word = self:AddChild(Text(self.font, self.size, v, self.colour))

        local w, h = word:GetRegionSize()
        w = w * width_factor

        table.insert(self.words, word)

        sum_width = sum_width + w
    end


    local cur_x = -sum_width / 2
    for k, word in pairs(self.words) do
        local w, h = word:GetRegionSize()
        w = w * width_factor

        local my_x = cur_x + 0.5 * w

        word:SetPosition(my_x, 0)
        table.insert(self.words_pos, Vector3(my_x, 0, 0))

        cur_x = cur_x + w

        self:StartShaking(k, word)
    end
end

function StariliadShakingText:StartShaking(index, word)
    local period = 1 * FRAMES
    local move_range = 2

    word.inst:DoPeriodicTask(period, function()
        local pos = word:GetPosition()
        local target_pos = Vector3(GetRandomMinMax(-move_range, move_range), GetRandomMinMax(-move_range, move_range), 0) +
            self.words_pos[index]

        word:CancelMoveTo(false)
        word:MoveTo(pos, target_pos, period)
    end)
    -- local max_angle = 10
    -- local angle_change = 8

    -- word.inst:DoPeriodicTask(period, function()
    --     local cur_angle = word:GetRotation()

    --     local cands = {}

    --     if cur_angle + angle_change < max_angle then
    --         table.insert(cands, GetRandomMinMax(cur_angle + angle_change, max_angle))
    --     end

    --     if cur_angle - angle_change > -max_angle then
    --         table.insert(cands, GetRandomMinMax(-max_angle, cur_angle - angle_change))
    --     end

    --     if #cands == 0 then
    --         table.insert(cands, GetRandomMinMax(-max_angle, max_angle))
    --     end

    --     -- local nxt_angle
    --     -- if math.abs(cur_angle) < 1e-6 then
    --     --     nxt_angle = GetRandomMinMax(-max_angle, max_angle)
    --     -- elseif cur_angle > 0 then
    --     --     nxt_angle = -max_angle
    --     -- else
    --     --     nxt_angle = max_angle
    --     -- end



    --     word:CancelRotateTo(false)
    --     word:RotateTo(cur_angle, GetRandomItem(cands), period)
    --     -- word:RotateTo(cur_angle, nxt_angle, period)
    -- end)

    -- word.inst:DoStaticPeriodicTask(0, function()
    --     -- local cur_angle = word:GetRotation()
    --     -- local nxt_angle = GetRandomMinMax(-10, 10)

    --     -- word:CancelRotateTo(false)
    --     -- word:RotateTo(cur_angle, nxt_angle, period)

    --     local cur_angle = word:GetRotation()

    --     word:SetRotation(GetRandomMinMax(-10, 10))
    -- end)
end

function StariliadShakingText:SetTarget(target, symbol, offset)
    self.target = target
    self.symbol = symbol
    self.offset = offset or Vector3(0, 0, 0)
end

function StariliadShakingText:OnUpdate()
    if self.target ~= nil and self.target:IsValid() then
        -- local facing = self.target.Transform:GetFacing()
        -- if facing == FACING_RIGHT or facing == FACING_UPRIGHT or facing == FACING_DOWNRIGHT
        --     or facing == FACING_LEFT or facing == FACING_UPLEFT or facing == FACING_DOWNLEFT then
        --     self.offset = Vector3(200, -800, 0)
        -- else
        --     self.offset = Vector3(0, -800, 0)
        -- end

        local x, y
        if self.target.AnimState ~= nil then
            x, y = TheSim:GetScreenPos(self.target.AnimState:GetSymbolPosition(self.symbol or "", self.offset.x,
                self.offset.y, self.offset.z))
        else
            x, y = TheSim:GetScreenPos(self.target.Transform:GetWorldPosition())
        end

        -- print("x y is:", x, y)
        self:SetPosition(x, y)
        self:Show()
    end
end

return StariliadShakingText
