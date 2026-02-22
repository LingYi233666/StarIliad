local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local star_colours = {
    { 1,         1,        1,        1 },
    { 0,         1,        1,        1 },
    { 0,         0,        1,        1 },
    { 1,         1,        0,        1 },
    { 154 / 255, 80 / 255, 49 / 255, 1 },
}

local StarIliadOpeningPart3 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart3")

    self.bg = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.bg:SetTint(0, 0, 0, 1)

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[3], 99999, 900)
    self.text:SetPosition(0, 100)
end)

function StarIliadOpeningPart3:SpawnSmallStar(center)
    local theta = math.random() * PI2
    local dir = Vector3(math.cos(theta), math.sin(theta))
    local max_radius = 1200
    local invisible_radius = 100
    local shown_radius = 200
    local stop_pos = center + dir * max_radius

    local shard = self:AddChild(Image("images/global.xml", "square.tex"))
    local sz = math.random(2, 3)
    local r, g, b, a = unpack(GetRandomItem(star_colours))
    local max_scale = GetRandomMinMax(1, 2)
    a = GetRandomMinMax(0.75, 1)

    shard.sides = {}

    shard:SetTint(r, g, b, 0)
    shard:SetSize(sz, sz)
    shard:SetPosition(center)
    shard:MoveTo(center, stop_pos, GetRandomMinMax(3, 10), function()
        shard:Kill()
    end)

    if sz * max_scale >= 3 and math.random() < 0.5 then
        shard:SetTint(1, 1, 1, 0)

        local side_sz = sz * 0.5
        local factor = sz * 0.5 + side_sz * 0.5
        local offsets = {
            Vector3(factor, 0, 0),
            Vector3(-factor, 0, 0),
            Vector3(0, factor, 0),
            Vector3(0, -factor, 0),
        }

        for _, offset in pairs(offsets) do
            local side = shard:AddChild(Image("images/global.xml", "square.tex"))
            side:SetTint(r, g, b, 0)
            side:SetSize(side_sz, side_sz)
            side:SetPosition(offset)

            table.insert(shard.sides, side)
        end
    end

    shard.task = shard.inst:DoPeriodicTask(0, function()
        local pos = shard:GetPosition()
        local dist = (pos - center):Length()
        local alpha = 0
        if dist < invisible_radius then
            alpha = 0
        elseif dist > shown_radius then
            alpha = 1
        else
            alpha = Remap(dist, invisible_radius, shown_radius, 0, a)
        end

        if #shard.sides > 0 then
            shard:SetTint(1, 1, 1, alpha)
            for _, side in pairs(shard.sides) do
                side:SetTint(r, g, b, alpha)
            end
        else
            shard:SetTint(r, g, b, alpha)
        end

        shard:SetScale(Remap(dist, 0, max_radius, 1, max_scale))
    end)
end

function StarIliadOpeningPart3:Play()
    self.task = self.inst:DoPeriodicTask(0, function()
        for i = 1, 3 do
            self:SpawnSmallStar(Vector3(0, 40))
        end
    end)
end

return StarIliadOpeningPart3
