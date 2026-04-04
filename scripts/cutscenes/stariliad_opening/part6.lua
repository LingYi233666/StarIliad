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

local function MakeShipRoot()
    local ship_root = Widget()

    ship_root.ship = ship_root:AddChild(MakeCutsceneObject("blythe_ship1"))

    ship_root.flame1 = ship_root:AddChild(UIAnim())
    ship_root.flame1:GetAnimState():SetBank("fire")
    ship_root.flame1:GetAnimState():SetBuild("fire")
    ship_root.flame1:GetAnimState():PlayAnimation("level1", true)
    ship_root.flame1:GetAnimState():SetDeltaTimeMultiplier(1.33)
    -- ship_root.flame:GetAnimState():SetBank("warg_mutated_breath_fx")
    -- ship_root.flame:GetAnimState():SetBuild("warg_mutated_breath_fx")
    -- ship_root.flame:GetAnimState():PlayAnimation("flame1_loop", true)
    ship_root.flame1:SetPosition(-220, -65)
    ship_root.flame1:SetRotation(-90)
    ship_root.flame1:SetScale(1, 0.35)
    -- ship_root.flame1:MoveToBack()

    ship_root.flame2 = ship_root:AddChild(UIAnim())
    ship_root.flame2:GetAnimState():SetBank("coldfire_fire")
    ship_root.flame2:GetAnimState():SetBuild("coldfire_fire")
    ship_root.flame2:GetAnimState():PlayAnimation("level1", true)
    ship_root.flame2:GetAnimState():SetDeltaTimeMultiplier(1.5)
    ship_root.flame2:SetPosition(-130, -65)
    ship_root.flame2:SetRotation(-90)
    ship_root.flame2:SetScale(2, 0.5)
    ship_root.flame2:Hide()

    ship_root.tail_task = ship_root.inst:DoPeriodicTask(0, function()
        local tail = ship_root:AddChild(UIAnim())
        tail:GetAnimState():SetBank("lavaarena_blowdart_attacks")
        tail:GetAnimState():SetBuild("lavaarena_blowdart_attacks")
        tail:GetAnimState():PlayAnimation("attack3", true)
        tail:GetAnimState():SetAddColour(1, 1, 1, 1)
        tail:SetScale(0.4, 0.1)

        local start_pos = Vector3(0, 0)
        tail:SetPosition(start_pos)
        tail:MoveTo(start_pos, start_pos - Vector3(500, 0), 1)
    end)

    return ship_root
end


local star_colours = {
    { 1, 1, 1, 1 },
    { 0, 1, 1, 1 },
    { 0, 0, 1, 1 },
    { 1, 1, 0, 1 },
    { 1, 0, 0, 1 },
}

local StarIliadOpeningPart6 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart6")

    self.cosmic = self:AddChild(Image("images/global.xml", "square.tex"))
    self.cosmic:SetVRegPoint(ANCHOR_MIDDLE)
    self.cosmic:SetHRegPoint(ANCHOR_MIDDLE)
    self.cosmic:SetVAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetHAnchor(ANCHOR_MIDDLE)
    self.cosmic:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.cosmic:SetTint(0, 0, 0, 1)

    self.stars_layout = self:AddChild(Widget("stars_layout"))

    self.blythe_ship = self:AddChild(MakeShipRoot())
    self.blythe_ship:SetPosition(-880, 0)
    self.blythe_ship:SetScale(0.66)

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[6], 99999, 900)
    self.text:SetPosition(0, 100)
end)

function StarIliadOpeningPart6:EmitStar(start_pos, stop_pos, duration)
    local star = self.stars_layout:AddChild(Image("images/global.xml", "square.tex"))
    local sz = math.random(1, 3)
    local r, g, b, a = unpack(GetRandomItem(star_colours))
    a = math.random()
    star:SetTint(r, g, b, a)
    star:SetSize(sz, sz)

    star:SetPosition(start_pos)

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

function StarIliadOpeningPart6:Play()
    self.inst:DoTaskInTime(2, function()
        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/ship_slide")

        local ship_start_pos = self.blythe_ship:GetPosition()
        local ship_stop_pos = Vector3(0, 0)
        self.blythe_ship:MoveTo(ship_start_pos, ship_stop_pos, 3)
    end)

    -- StarIliadDebug.CUTSCENE.parts[6].blythe_ship.flame1:SetPosition(-130, -65)
    self.inst:DoTaskInTime(6, function()
        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/ship_charge")

        local ship_start_pos = self.blythe_ship:GetPosition()
        local ship_stop_pos = Vector3(-100, 0)
        self.blythe_ship:MoveTo(ship_start_pos, ship_stop_pos, 1)
    end)

    self.inst:DoTaskInTime(7.5, function()
        local ship_pos = self.blythe_ship:GetPosition()
        local ship_stop_pos = Vector3(1800, 0)

        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/ship_fly")

        -- self.blythe_ship.flame3:GetAnimState():PlayAnimation("puff_" .. math.random(1, 3))

        local flame3 = self:AddChild(UIAnim())
        flame3:GetAnimState():SetBank("halloween_embers_cold")
        flame3:GetAnimState():SetBuild("halloween_embers_cold")
        flame3:GetAnimState():PlayAnimation("puff_" .. math.random(1, 3))
        flame3:SetPosition(ship_pos.x, ship_pos.y - 50)
        flame3:SetRotation(-90)
        flame3:SetScale(1, 0.2)

        self.inst:DoTaskInTime(0.1, function()
            self.blythe_ship.flame1:Hide()
            self.blythe_ship.flame2:Show()
        end)


        self.blythe_ship:MoveTo(ship_pos, ship_stop_pos, 2)
    end)

    local half_w = 680
    local half_h = 500

    for i = 1, 100 do
        local start_pos = Vector3(half_w, math.random(-half_h, half_h))
        local stop_pos = Vector3(-start_pos.x, start_pos.y)
        local duration = GetRandomMinMax(0.8, 1.2)

        local star = self:EmitStar(start_pos, stop_pos, duration)
        star.start_time = star.start_time - GetRandomMinMax(0.8, 1.2)
    end

    self.inst:DoPeriodicTask(0, function()
        local start_pos = Vector3(half_w, math.random(-half_h, half_h))
        local stop_pos = Vector3(-start_pos.x, start_pos.y)
        local duration = GetRandomMinMax(0.8, 1.2)

        self:EmitStar(start_pos, stop_pos, duration)
    end)
end

return StarIliadOpeningPart6
