local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local function MakeCutsceneObject(anim)
    local obj = UIAnim()
    obj:GetAnimState():SetBank("stariliad_cutscene_opening")
    obj:GetAnimState():SetBuild("stariliad_cutscene_opening")
    obj:GetAnimState():PlayAnimation(anim)
    obj:GetAnimState():UsePointFiltering(true)

    return obj
end


local star_colours = {
    { 1, 1, 1, 1 },
    { 0, 1, 1, 1 },
    { 0, 0, 1, 1 },
    { 1, 1, 0, 1 },
    { 1, 0, 0, 1 },
}

local StarIliadOpeningPart4 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart4")

    self.cosmic = self:AddChild(Image("images/global.xml", "square.tex"))
    self.cosmic:SetVRegPoint(ANCHOR_MIDDLE)
    self.cosmic:SetHRegPoint(ANCHOR_MIDDLE)

    self.cosmic:SetVAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetHAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.cosmic:SetTint(0, 0, 0, 1)

    self.stars = {}
    for i = 1, 100 do
        local star = self:AddChild(Image("images/global.xml", "square.tex"))
        local sz = math.random(1, 5)
        local r, g, b, a = unpack(GetRandomItem(star_colours))
        a = math.random()
        star:SetTint(r, g, b, a)
        star:SetSize(sz, sz)
        star:SetPosition(math.random(-700, 700), math.random(-250, 540))

        table.insert(self.stars, star)
    end

    self.planet = self:AddChild(MakeCutsceneObject("planet4"))
    self.planet:SetPosition(-50, 0)
    self.planet:SetScale(0.7)

    self.moon = self:AddChild(MakeCutsceneObject("moon"))
    self.moon:SetPosition(400, 110)
    self.moon:SetScale(0.4)

    -- StarIliadDebug.CUTSCENE.parts[4].moon:SetPosition()

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[4], 99999, 900)
    self.text:SetPosition(0, 100)
end)

function StarIliadOpeningPart4:Play()
    local planet_start_pos = self.planet:GetPosition()
    local planet_stop_pos = planet_start_pos + Vector3(28, 0)

    local moon_start_pos = self.moon:GetPosition()
    local moon_stop_pos = moon_start_pos + Vector3(-28, 0)

    local max_duration = 7

    self.start_time = GetStaticTime()

    self.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - self.start_time

        if cur_t <= max_duration then
            -- local planet_pos = Remap(cur_t, 0, max_duration, planet_start_pos, planet_stop_pos)
            -- local moon_pos = Remap(cur_t, 0, max_duration, moon_start_pos, moon_stop_pos)

            local planet_pos = planet_start_pos + (planet_stop_pos - planet_start_pos) * cur_t / max_duration
            local moon_pos = moon_start_pos + (moon_stop_pos - moon_start_pos) * cur_t / max_duration

            self.planet:SetPosition(planet_pos)
            self.moon:SetPosition(moon_pos)
        end
    end)
end

return StarIliadOpeningPart4
