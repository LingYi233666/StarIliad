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

    ship_root.ship = ship_root:AddChild(MakeCutsceneObject("blythe_ship2"))

    local flame_pos_list = {
        Vector3(-60, -20),
        Vector3(60, -20),
        Vector3(0, -50),
    }

    -- local tint1 = { 129 / 255, 197 / 255, 248 / 255, 1.0 }
    -- local tint1_1 = { 129 / 255, 197 / 255, 248 / 255, 0.5 }
    -- local tint2 = { 57 / 255, 124 / 255, 182 / 255, 0.9 }

    -- local tint1 = { 1, 1, 1, 1 }
    -- local tint1_1 = { 129 / 255, 197 / 255, 248 / 255, 1 }

    local tint1 = { 1, 1, 1, 1 }
    local tint1_1 = { 1, 1, 1, 0.5 }

    for _, pos in pairs(flame_pos_list) do
        local flame = ship_root:AddChild(Image("images/ui/stariliad_circle2.xml",
            "stariliad_circle2.tex"))
        flame:SetPosition(pos)
        flame:SetSize(128, 128)
        flame:SetTint(unpack(tint1))
        flame.inst:DoPeriodicTask(0, function()
            if flame.flag then
                flame:SetTint(unpack(tint1))
            else
                flame:SetTint(unpack(tint1_1))
            end
            flame.flag = not flame.flag
        end)
    end
    -- ship_root.flame1 = ship_root:AddChild(UIAnim())
    -- ship_root.flame1:GetAnimState():SetBank("coldfire_fire")
    -- ship_root.flame1:GetAnimState():SetBuild("coldfire_fire")
    -- ship_root.flame1:GetAnimState():PlayAnimation("level1", true)
    -- -- ship_root.flame:GetAnimState():SetBank("warg_mutated_breath_fx")
    -- -- ship_root.flame:GetAnimState():SetBuild("warg_mutated_breath_fx")
    -- -- ship_root.flame:GetAnimState():PlayAnimation("flame1_loop", true)
    -- ship_root.flame1:SetPosition(0, 0)
    -- ship_root.flame1:SetRotation(90)
    -- ship_root.flame1:SetScale(0.5, 1)

    return ship_root
end


local star_colours = {
    { 1, 1, 1, 1 },
    { 0, 1, 1, 1 },
    { 0, 0, 1, 1 },
    { 1, 1, 0, 1 },
    { 1, 0, 0, 1 },
}

local StarIliadOpeningPart7 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart7")

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
    self.planet:SetPosition(150, 0)
    self.planet:SetScale(0.7)

    self.moon = self:AddChild(MakeCutsceneObject("moon"))
    self.moon:SetPosition(600, 110)
    self.moon:SetScale(0.4)

    self.blythe_ship = self:AddChild(MakeShipRoot())
    -- self.blythe_ship:SetPosition(-800, -200)
    -- self.blythe_ship:SetScale(0.66)
    self.blythe_ship:Hide()

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[7], 99999, 1000)
    self.text:SetPosition(0, 100)
end)

local function SolveAC(p1, p2)
    local x1, y1, x2, y2 = p1.x, p1.y, p2.x, p2.y

    local a = (y1 - y2) / (x1 * x1 - x2 * x2)
    local c = y1 - a * x1 * x1

    return a, c
end

function StarIliadOpeningPart7:Play()
    local start_pos = Vector3(-1000, -200)
    local stop_pos = Vector3(200, 70)
    -- local start_pos = Vector3(-1000, -300)
    -- local stop_pos = Vector3(150, 100)

    local start_degree = 30
    local stop_degree = 83

    local start_scale = 2
    local stop_scale = 0.01

    local tail_time = 3.5
    local duration = 4


    self.inst:DoTaskInTime(1, function()
        local start_time = GetStaticTime()
        local a, c = SolveAC(start_pos, stop_pos)

        local last_ship_pos = nil
        local last_ship_t = nil
        self.fly_task = self.inst:DoPeriodicTask(0, function()
            local t1 = GetStaticTime() - start_time
            if t1 <= duration then
                local x = easing.inQuad(t1, start_pos.x, stop_pos.x - start_pos.x, duration)
                local y = a * x * x + c;
                local ship_pos = Vector3(x, y)

                self.blythe_ship:SetPosition(ship_pos)

                local degree = easing.inQuad(t1, start_degree, stop_degree - start_degree, duration)
                self.blythe_ship:SetRotation(degree)

                local scale = easing.inQuad(t1, start_scale, stop_scale - start_scale, duration)
                self.blythe_ship:SetScale(scale)

                if not self.blythe_ship.shown then
                    self.blythe_ship:Show()
                end

                if t1 >= tail_time and last_ship_pos ~= nil then
                    local start_sz = 16
                    local stop_sz = 3

                    local start_tint = { 1, 1, 1, 1 }
                    local stop_tint = { 1, 1, 1, 0 }
                    -- local start_tint = { 129 / 255, 197 / 255, 248 / 255, 1.0 }
                    -- local stop_tint = { 129 / 255, 197 / 255, 248 / 255, 0 }

                    local flame_duration = 0.5

                    local time_delta = t1 - last_ship_t

                    local pos_delta = ship_pos - last_ship_pos
                    local delta_len = pos_delta:Length()
                    local pos_delta_norm = pos_delta / delta_len
                    local step_len = 1
                    local num_steps = math.floor(delta_len / step_len)
                    step_len = delta_len / num_steps

                    for i = 0, num_steps do
                        local flame = self:AddChild(Image("images/ui/stariliad_circle2.xml",
                            "stariliad_circle2.tex"))
                        flame:SetPosition(last_ship_pos + pos_delta_norm * i * step_len)
                        flame:SetSize(start_sz, start_sz)
                        flame:SetTint(unpack(start_tint))
                        flame.start_time = GetStaticTime()

                        flame.inst:DoPeriodicTask(0, function()
                            local cur_t = GetStaticTime() - flame.start_time + (num_steps - i) * time_delta / num_steps
                            if cur_t <= flame_duration then
                                local sz = easing.linear(cur_t, start_sz, stop_sz - start_sz, flame_duration)
                                local tint = { 0, 0, 0, 0 }

                                for i = 1, 4 do
                                    tint[i] = easing.linear(cur_t, start_tint[i], stop_tint[i] - start_tint[i],
                                        flame_duration)
                                end

                                flame:SetSize(sz, sz)
                                flame:SetTint(unpack(tint))
                            else
                                flame:Kill()
                            end
                        end)
                    end
                end

                last_ship_pos = Vector3(x, y)
                last_ship_t = t1
            else
                local pos = self.blythe_ship:GetPosition()

                local fx = self:AddChild(UIAnim())
                fx:GetAnimState():SetBank("crab_king_shine")
                fx:GetAnimState():SetBuild("crab_king_shine")
                fx:GetAnimState():PlayAnimation("shine")
                fx:SetScale(0.2)
                fx:SetPosition(pos)
                fx.inst:ListenForEvent("animover", function()
                    fx:Kill()
                end)

                self.blythe_ship:Hide()

                self.fly_task:Cancel()
            end
        end)
    end)
end

return StarIliadOpeningPart7
