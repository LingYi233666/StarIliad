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

local StarIliadOpeningPart5 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart5")

    self.cosmic = self:AddChild(Image("images/global.xml", "square.tex"))
    self.cosmic:SetVRegPoint(ANCHOR_MIDDLE)
    self.cosmic:SetHRegPoint(ANCHOR_MIDDLE)
    self.cosmic:SetVAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetHAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.cosmic:SetTint(0, 0, 0, 1)

    self.stars_layout = self:AddChild(Widget("stars_layout"))
    self.stars_region = { 1280, 1000 }

    self.enemy_ships = self:AddChild(MakeCutsceneObject("enemy_ships"))
    self.enemy_ships:SetPosition(0, 0)
    self.enemy_ships:SetScale(0.66)

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[5], 99999, 900)
    self.text:SetPosition(0, 100)
end)

function StarIliadOpeningPart5:EmitStar(start_pos, stop_pos, duration)
    local star = self.stars_layout:AddChild(Image("images/global.xml", "square.tex"))
    local sz = math.random(1, 5)
    local r, g, b, a = unpack(GetRandomItem(star_colours))
    a = math.random()
    star:SetTint(r, g, b, a)
    star:SetSize(sz, sz)

    star:SetPosition(start_pos)
    -- star:MoveTo(start_pos, stop_pos, duration, function()
    --     star:Kill()
    -- end)
    star.start_time = GetStaticTime()

    local delta_pos = stop_pos - start_pos

    star.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - star.start_time

        if cur_t <= duration then
            star:SetPosition(start_pos + delta_pos * (cur_t / duration))
        else
            star:Kill()
        end
    end)

    return star
end

function StarIliadOpeningPart5:Play()
    local theta = 45 * DEGREES
    local direction = Vector3(-math.cos(theta), math.sin(theta))

    local function emit_fn()
        local width, height = unpack(self.stars_region)
        local dist = math.sqrt(width * width + height * height) * 0.8
        local duration = GetRandomMinMax(1.5, 2)

        local rand_value = math.random() * (width + height)
        if rand_value > width then
            local start_pos = Vector3(width * 0.5, rand_value - width - height * 0.5)
            local stop_pos = start_pos + direction * dist

            return self:EmitStar(start_pos, stop_pos, duration)
        else
            local start_pos = Vector3(rand_value - 0.5 * width, -0.5 * height)
            local stop_pos = start_pos + direction * dist

            return self:EmitStar(start_pos, stop_pos, duration)
        end
    end


    for i = 1, 200 do
        local star = emit_fn()
        star.start_time = star.start_time - GetRandomMinMax(0, 2)
    end

    self.inst:DoPeriodicTask(0, function()
        for i = 1, 2 do
            emit_fn()
        end
    end)
end

return StarIliadOpeningPart5
