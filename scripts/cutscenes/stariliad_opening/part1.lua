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

local ships_data = {
    { Vector3(-300, 150),  "ships1_0", 0.6 },
    { Vector3(-350, -50),  "ships1_1", 0.3 },

    { Vector3(-250, 0),    "ships1_2", 0.66 },
    { Vector3(-270, 250),  "ships1_2", 0.66 },
    { Vector3(-450, 190),  "ships1_2", 0.66 },
    { Vector3(-440, 70),   "ships1_2", 0.66 },
    { Vector3(-460, -120), "ships1_2", 0.66 },
    { Vector3(-260, -170), "ships1_2", 0.66 },

    -------------------------------------------

    { Vector3(300, 150),   "ships2_0" },
    { Vector3(350, -50),   "ships2_0" },

    { Vector3(250, 0),     "ships2_0", 0.8 },
    { Vector3(270, 250),   "ships2_0", 0.8 },
    { Vector3(450, 190),   "ships2_0", 0.8 },
    { Vector3(440, 70),    "ships2_0", 0.8 },
    { Vector3(460, -120),  "ships2_0", 0.8 },
    { Vector3(260, -170),  "ships2_0", 0.8 },
}

local star_colours = {
    { 1, 1, 1, 1 },
    { 0, 1, 1, 1 },
    { 0, 0, 1, 1 },
    { 1, 1, 0, 1 },
}

local StarIliadOpeningPart1 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart1")

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

    self.planet = self:AddChild(MakeCutsceneObject("planet1"))

    for i = 1, 4 do
        self.planet:GetAnimState():SetSymbolMultColour("planet_1_part_" .. i, 0, 0, 0, 1)
    end
    self.planet:GetAnimState():SetSymbolAddColour("planet_1_part_1", 1, 1, 1, 1)
    self.planet:GetAnimState():SetSymbolAddColour("planet_1_part_2", 59 / 255, 177 / 255, 255 / 255, 1)
    self.planet:GetAnimState():SetSymbolAddColour("planet_1_part_3", 79 / 255, 59 / 255, 255 / 255, 1)
    self.planet:GetAnimState():SetSymbolAddColour("planet_1_part_4", 0, 0, 0, 1)

    self.planet:SetScale(3.2, 3.2)
    self.planet:SetPosition(0, 40)

    self.ships = {}
    for _, v in pairs(ships_data) do
        local pos, anim, scale = v[1], v[2], v[3]

        local ship = self:AddChild(MakeCutsceneObject(anim))
        ship:SetPosition(pos)
        if scale then
            ship:SetScale(scale, scale)
        end

        table.insert(self.ships, ship)
    end

    self.sweep_beam_root = self:AddChild(Widget("sweep_beam_root"))
    -- self.sweep_beam_root:SetPosition(0, 1500)
    self.sweep_beam_root:SetPosition(-500, 1500)
    -- self.sweep_beam_root:SetRotation(35)
    self.sweep_beam_root:Hide()

    self.sweep_beams = {}
    for i = 1, 3 do
        local sweep_beam = self.sweep_beam_root:AddChild(UIAnim())
        sweep_beam:GetAnimState():SetBank("lunar_fx")
        sweep_beam:GetAnimState():SetBuild("moonbase_fx")
        sweep_beam:GetAnimState():HideSymbol("lunar_spotlight")
        -- sweep_beam:GetAnimState():PlayAnimation("lunar_back_loop", true)
        -- sweep_beam:GetAnimState():UsePointFiltering(true)
        sweep_beam:SetPosition(0, -2500)

        table.insert(self.sweep_beams, sweep_beam)
    end

    self.star_destroy_beam = self:AddChild(UIAnim())
    self.star_destroy_beam:GetAnimState():SetBank("wagboss_beam")
    self.star_destroy_beam:GetAnimState():SetBuild("wagboss_beam")
    -- self.star_destroy_beam:GetAnimState():UsePointFiltering(true)
    self.star_destroy_beam:SetScale(0.1, 0.1)
    self.star_destroy_beam:SetPosition(0, 180)

    -- self.weapon = self:AddChild(MakeCutsceneObject("weapon"))
    -- self.weapon:GetAnimState():SetAddColour(0.5, 0, 0.5, 1)
    -- self.weapon:SetPosition(0, 500)
    -- self.weapon:SetScale(3.2, 3.2)

    self.weapon = self:AddChild(UIAnim())
    self.weapon:GetAnimState():SetBank("alterguardian_phase3")
    self.weapon:GetAnimState():SetBuild("alterguardian_phase3")
    self.weapon:GetAnimState():PlayAnimation("idle", true)
    self.weapon:GetAnimState():UsePointFiltering(true)
    self.weapon:SetPosition(0, 500)
    self.weapon:SetScale(0.2)

    self.flash = self:AddChild(Image("images/global.xml", "square.tex"))
    self.flash:SetVRegPoint(ANCHOR_MIDDLE)
    self.flash:SetHRegPoint(ANCHOR_MIDDLE)
    self.flash:SetVAnchor(ANCHOR_MIDDLE)
    self.flash:SetHAnchor(ANCHOR_MIDDLE)
    self.flash:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.flash:SetTint(0, 0, 0, 0)

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[1], 99999, 900)
    self.text:SetPosition(0, 100)
end)

function StarIliadOpeningPart1:Play()
    self:StartBeamFight()

    -- self.inst:DoTaskInTime(2.67, function()
    --     self:LaunchSweepBeam(2.7)
    -- end)

    self.inst:DoTaskInTime(3.67, function()
        self:StopBeamFight()
        -- self:LaunchSweepBeam(35, -35, 1.7)
        self:LaunchSweepBeam(15, -50, 1.7)
    end)

    self.inst:DoTaskInTime(5.47, function()
        self:LaunchStarDestroyBeam(1.4)
    end)

    self.inst:DoTaskInTime(5.77, function()
        self:PlanetTintTo("planet_1_part_1", { 250 / 255, 180 / 255, 42 / 255 }, 0.3)
        self:PlanetTintTo("planet_1_part_2", { 247 / 255, 138 / 255, 131 / 255 }, 0.3)
        self:PlanetTintTo("planet_1_part_3", { 159 / 255, 1 / 255, 202 / 255 }, 0.3)

        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/planet_explode_pre")
    end)

    self.inst:DoTaskInTime(6.07, function()
        self:PlanetTintTo("planet_1_part_1", { 228 / 255, 53 / 255, 29 / 255 }, 0.2)
        self:PlanetTintTo("planet_1_part_2", { 255 / 255, 173 / 255, 70 / 255 }, 0.2)
        self:PlanetTintTo("planet_1_part_3", { 197 / 255, 0 / 255, 20 / 255 }, 0.2)
    end)

    self.inst:DoTaskInTime(6.57, function()
        self:PlanetTintTo("planet_1_part_1", { 250 / 255, 189 / 255, 182 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 242 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 251 / 255, 214 / 255, 125 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(6.72, function()
        self:PlanetTintTo("planet_1_part_1", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(6.87, function()
        self:PlanetTintTo("planet_1_part_1", { 250 / 255, 189 / 255, 182 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 242 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 251 / 255, 214 / 255, 125 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(7.02, function()
        self:PlanetTintTo("planet_1_part_1", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(7.17, function()
        self:PlanetTintTo("planet_1_part_1", { 250 / 255, 189 / 255, 182 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 242 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 251 / 255, 214 / 255, 125 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(7.32, function()
        self:PlanetTintTo("planet_1_part_1", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 255 / 255, 255 / 255, 255 / 255 }, 0.15)
    end)

    self.inst:DoTaskInTime(7.47, function()
        self:PlanetTintTo("planet_1_part_1", { 250 / 255, 189 / 255, 182 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_2", { 242 / 255, 255 / 255, 255 / 255 }, 0.15)
        self:PlanetTintTo("planet_1_part_3", { 251 / 255, 214 / 255, 125 / 255 }, 0.15)

        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/planet_explode")
    end)

    self.inst:DoTaskInTime(7.62, function()
        self:PlanetTintTo("planet_1_part_1", { 255 / 255, 255 / 255, 255 / 255 }, 0.1)
        self:PlanetTintTo("planet_1_part_2", { 255 / 255, 255 / 255, 255 / 255 }, 0.1)
        self:PlanetTintTo("planet_1_part_3", { 255 / 255, 255 / 255, 255 / 255 }, 0.1)
    end)

    self.inst:DoTaskInTime(7.72, function()
        self:PlanetDestroy()
    end)

    self.inst:DoTaskInTime(10.5, function()
        self:WeaponSlideIn(8)
    end)
end

function StarIliadOpeningPart1:MakeExplode(pos)
    local explode_root = self:AddChild(Widget("explode_root"))
    explode_root:SetPosition(pos)

    explode_root.anim = explode_root:AddChild(UIAnim())
    explode_root.anim:GetAnimState():SetBank("slingshotammo")
    explode_root.anim:GetAnimState():SetBuild("slingshotammo")
    explode_root.anim:GetAnimState():PlayAnimation("used_gunpowder")
    explode_root.anim:GetAnimState():UsePointFiltering(true)

    for i = 0, 13 do
        explode_root.anim:GetAnimState():HideSymbol("dfs" .. i)
    end

    explode_root.anim:SetPosition(0, -30)
    explode_root.anim:SetScale(0.2, 0.2)

    explode_root.anim.inst:ListenForEvent("animover", function()
        explode_root:Kill()
    end)

    return explode_root
end

function StarIliadOpeningPart1:LaunchBeam(start_pos, end_pos, speed, emit_explode)
    local obj = UIAnim()
    obj:GetAnimState():SetBank("lavaarena_blowdart_attacks")
    obj:GetAnimState():SetBuild("lavaarena_blowdart_attacks")
    obj:GetAnimState():PlayAnimation("attack_3", true)
    obj:GetAnimState():UsePointFiltering(true)
    obj:SetScale(0.4, 0.2)
    obj:SetPosition(start_pos)

    local delta = end_pos - start_pos
    local t = delta:Length() / speed
    obj:SetRotation(math.atan2(delta.y, delta.x) * RADIANS)
    obj.start_time = GetStaticTime()
    obj.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - obj.start_time

        obj:SetPosition(start_pos + delta * cur_t / t)
        if cur_t >= t then
            if emit_explode then
                self:MakeExplode(obj:GetPosition())
                TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/laser_hit")
            end
            obj:Kill()
        end
    end)

    self:AddChild(obj)

    TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/laser")

    return obj
end

function StarIliadOpeningPart1:LaunchBeams()
    for k, ship in pairs(self.ships) do
        if math.random() < 0.75 then
            self.inst:DoTaskInTime(GetRandomMinMax(0, 1), function()
                local offset = Vector3(50, 0)
                local offset2 = Vector3(math.random(300, 700), 0)
                if k >= 9 then
                    offset = Vector3(-50, 0)
                    offset2 = Vector3(-math.random(300, 700), 0)
                end

                local start_pos = ship:GetPosition() + offset
                local beam = self:LaunchBeam(start_pos, start_pos + offset2, 2500, math.random() < 0.66)

                if k < 9 then
                    beam:GetAnimState():SetMultColour(0, 0, 0, 1)
                    beam:GetAnimState():SetAddColour(0, 245 / 255, 211 / 255, 1)
                end
            end)
        end
    end

    -- local k, ship = GetRandomItemWithIndex(self.ships)

    -- local offset = Vector3(50, 0)
    -- local offset2 = Vector3(math.random(300, 700), 0)
    -- if k >= 9 then
    --     offset = Vector3(-50, 0)
    --     offset2 = Vector3(-math.random(300, 700), 0)
    -- end

    -- local start_pos = ship:GetPosition() + offset
    -- local beam = self:LaunchBeam(start_pos, start_pos + offset2, 2500, math.random() < 0.66)

    -- if k < 9 then
    --     beam:GetAnimState():SetMultColour(0, 0, 0, 1)
    --     beam:GetAnimState():SetAddColour(0, 245 / 255, 211 / 255, 1)
    -- end
end

function StarIliadOpeningPart1:StartBeamFight(delay)
    -- self.beam_fight_task = self.inst:DoTaskInTime(delay or GetRandomMinMax(0.5, 1), function()
    --     self:LaunchBeams()

    --     self:StopBeamFight()
    --     self:StartBeamFight()
    -- end)

    self:LaunchBeams()
    self.beam_fight_task = self.inst:DoTaskInTime(delay or 1, function()
        if self.beam_fight_task then
            self.beam_fight_task:Cancel()
        end
        self:StartBeamFight()
    end)
end

function StarIliadOpeningPart1:StopBeamFight()
    if self.beam_fight_task then
        self.beam_fight_task:Cancel()
    end
    self.beam_fight_task = nil
end

function StarIliadOpeningPart1:LaunchSweepBeam(start_deg, stop_deg, duration)
    -- local start_deg = 35
    -- local stop_deg = -35
    -- duration = duration or 1.7

    self.sweep_beam_root:Show()

    for _, v in pairs(self.sweep_beams) do
        v:GetAnimState():PlayAnimation("lunar_back_loop", true)
    end

    if self.sweep_beam_root.task then
        self.sweep_beam_root.task:Cancel()
    end

    self.sweep_beam_root.start_time = GetStaticTime()
    self.sweep_beam_root:SetRotation(start_deg)

    self.sweep_beam_root.task = self.sweep_beam_root.inst:DoPeriodicTask(0, function()
        local t = GetStaticTime() - self.sweep_beam_root.start_time
        local delta = stop_deg - start_deg
        -- local cur_deg = start_deg + delta * t / duration
        local cur_deg = easing.linear(t, start_deg, delta, duration)
        -- local cur_deg = easing.outCubic(t, start_deg, delta, duration)

        local cur_rad2 = (270 - cur_deg) * DEGREES
        local origin = self.sweep_beam_root:GetPosition()
        local pos_offset = Vector3(math.cos(cur_rad2), math.sin(cur_rad2))

        for _, ship in pairs(self.ships) do
            local ship_pos = ship:GetPosition()
            if ship.shown and StarIliadMath.GetDistPointToLine(origin, origin + pos_offset, ship_pos) < 50 then
                for i = 1, math.random(6, 8) do
                    local delay = (i == 1) and 0 or math.random() * 0.3
                    ship.inst:DoTaskInTime(delay, function()
                        local rand_rad = math.random() * PI2
                        local dist = math.random() * 50
                        self:MakeExplode(ship_pos + Vector3(math.cos(rand_rad), math.sin(rand_rad)) * dist)
                    end)
                end

                TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/ship_explode")

                ship:Hide()
            end
        end

        self.sweep_beam_root:SetRotation(cur_deg)

        if t >= duration then
            self.sweep_beam_root.task:Cancel()
            self.sweep_beam_root.task = nil
            self.sweep_beam_root:Hide()
        end
    end)

    TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/sweep_beam")
end

function StarIliadOpeningPart1:LaunchStarDestroyBeam(duration)
    if self.stop_star_destroy_beam_task then
        self.stop_star_destroy_beam_task:Cancel()
        self.stop_star_destroy_beam_task = nil
    end

    self.star_destroy_beam:GetAnimState():PlayAnimation("beam_pre")
    self.star_destroy_beam:GetAnimState():SetTime(0.9)
    self.star_destroy_beam:GetAnimState():PushAnimation("beam_loop", true)

    if duration then
        self.stop_star_destroy_beam_task = self.inst:DoTaskInTime(duration, function()
            self.star_destroy_beam:GetAnimState():PlayAnimation("beam_pst")
        end)
    end

    TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/sweep_beam")
end

function StarIliadOpeningPart1:PlanetTintTo(symbol, new_add_colour, duration)
    local task_name = "planet_tint_to_task_" .. symbol
    if self[task_name] then
        self[task_name]:Cancel()
        self[task_name] = nil
    end

    self.planet_tint_start_time = GetStaticTime()

    local old_r, old_g, old_b, old_a = self.planet:GetAnimState():GetSymbolAddColour(symbol)
    local new_r, new_g, new_b, new_a = unpack(new_add_colour)
    local d_r, d_g, d_b = new_r - old_r, new_g - old_g, new_b - old_b

    self[task_name] = self.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - self.planet_tint_start_time
        local factor = cur_t / duration
        local cur_r = old_r + d_r * factor
        local cur_g = old_g + d_g * factor
        local cur_b = old_b + d_b * factor

        if cur_t >= duration then
            self.planet:GetAnimState():SetSymbolAddColour(symbol, new_r, new_g, new_b, 1)
            self[task_name]:Cancel()
            self[task_name] = nil
        else
            self.planet:GetAnimState():SetSymbolAddColour(symbol, cur_r, cur_g, cur_b, 1)
        end
    end)
end

local function MakeRGBA(r, g, b, a)
    return { r = r, g = g, b = b, a = a }
end

function StarIliadOpeningPart1:MakePlanetShard(pos)
    local shard = self:AddChild(Image("images/global.xml", "square.tex"))
    local sz = math.random(3, 4)
    -- local r, g, b, a = unpack(GetRandomItem(star_colours))
    -- a = math.random()
    shard:SetTint(1, 1, 1, 1)

    shard:SetSize(sz, sz)
    shard:SetPosition(pos)

    -- shard.inst:DoPeriodicTask(3, function()
    --     shard:TintTo(MakeRGBA(1, 1, 1, 1), MakeRGBA(1, 0, 0, 1), 0.2, function()
    --         shard:TintTo(MakeRGBA(1, 0, 0, 1), MakeRGBA(0, 0, 0, 1), 0.2, function()
    --             shard:TintTo(MakeRGBA(0, 0, 0, 1), MakeRGBA(1, 0, 1, 1), 0.2, function()
    --                 shard:TintTo(MakeRGBA(1, 0, 1, 1), MakeRGBA(1, 1, 0, 1), 0.2, function()
    --                     shard:TintTo(MakeRGBA(1, 1, 0, 1), MakeRGBA(1, 1, 1, 1), 0.2, function()

    --                     end)
    --                 end)
    --             end)
    --         end)
    --     end)
    -- end, 4)

    -- shard.inst:DoPeriodicTask(3, function()
    --     shard:TintTo(MakeRGBA(1, 1, 1, 1), MakeRGBA(1, 0, 0, 1), 0.33, function()
    --         shard:TintTo(MakeRGBA(1, 0, 0, 1), MakeRGBA(1, 0, 1, 1), 0.33, function()
    --             shard:TintTo(MakeRGBA(1, 0, 1, 1), MakeRGBA(0, 0, 0, 1), 0.33, function()
    --                 shard:TintTo(MakeRGBA(0, 0, 0, 1), MakeRGBA(1, 1, 1, 1), 0.33, function()

    --                 end)
    --             end)
    --         end)
    --     end)
    -- end, 4)

    shard.inst:DoPeriodicTask(3, function()
        shard:TintTo(MakeRGBA(1, 1, 1, 1), MakeRGBA(1, 0, 0, 1), 0.33, function()
            shard:TintTo(MakeRGBA(1, 0, 0, 1), MakeRGBA(1, 1, 0, 1), 0.33, function()
                shard:TintTo(MakeRGBA(1, 1, 0, 1), MakeRGBA(1, 0, 1, 1), 0.33, function()
                    shard:TintTo(MakeRGBA(1, 0, 1, 1), MakeRGBA(1, 1, 1, 1), 0.33, function()

                    end)
                end)
            end)
        end)
    end, 4)

    -- shard.inst:DoPeriodicTask(3, function()
    --     shard:TintTo(MakeRGBA(1, 1, 1, 1), MakeRGBA(1, 1, 0, 1), 0.1, function()
    --         shard:TintTo(MakeRGBA(1, 1, 0, 1), MakeRGBA(1, 0, 0, 1), 0.1, function()
    --             shard:TintTo(MakeRGBA(1, 0, 0, 1), MakeRGBA(0, 0, 0, 1), 0.1, function()
    --                 shard:TintTo(MakeRGBA(0, 0, 0, 1), MakeRGBA(1, 0, 0, 1), 0.1, function()
    --                     shard:TintTo(MakeRGBA(1, 0, 0, 1), MakeRGBA(1, 0, 1, 1), 0.1, function()
    --                         shard:TintTo(MakeRGBA(1, 0, 1, 1), MakeRGBA(1, 1, 1, 1), 0.1, function()

    --                         end)
    --                     end)
    --                 end)
    --             end)
    --         end)
    --     end)
    -- end, 4)

    return shard
end

function StarIliadOpeningPart1:PlanetDestroy()
    self.planet:Hide()

    for i = 1, 100 do
        local theta = math.random() * PI2
        local radius = GetRandomMinMax(0, 200)
        local offset = Vector3(math.cos(theta), math.sin(theta)) * radius
        local delay = (i < 50) and 0 or math.random() * 2

        self.inst:DoTaskInTime(delay, function()
            local explode = self:MakeExplode(self.planet:GetPosition() + offset)
            explode:SetScale(2)

            if delay < 0.5 then
                explode.anim:GetAnimState():SetAddColour(1, 1, 1, 1)
            end

            self.flash:MoveToFront()

            if delay > 1 then
                TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/planet_explode_spark")
            end
        end)
    end

    self.inst:DoTaskInTime(0.25, function()
        local min_rad_a = 200
        local min_rad_b = 150

        local max_rad_a = 800
        local max_rad_b = 600

        local time_step = 0.25
        local time_sum = 2

        for i = 0, time_sum, time_step do
            self.inst:DoTaskInTime(i, function()
                for theta = 0, 360, 10 do
                    self.inst:DoTaskInTime(math.random() * 0.33, function()
                        local px = Remap(i, 0, time_sum, min_rad_a, max_rad_a) * math.cos(theta * DEGREES)
                        local py = Remap(i, 0, time_sum, min_rad_b, max_rad_b) * math.sin(theta * DEGREES)

                        local explode = self:MakeExplode(self.planet:GetPosition() + Vector3(px, py))
                        explode:SetScale(2)

                        -- TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/planet_explode_spark")

                        self.flash:MoveToFront()
                    end)
                end
            end)
        end
    end)

    TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/planet_explode_spark2")

    -- cosmic flash

    self.flash:TintTo(MakeRGBA(0, 0, 0, 0), MakeRGBA(1, 1, 1, 0.8), 0.05)

    self.inst:DoTaskInTime(0.05, function()
        self.flash:TintTo(MakeRGBA(1, 1, 1, 0.8), MakeRGBA(0, 0, 0, 0), 0.05)
    end)

    self.inst:DoTaskInTime(0.1, function()
        self.flash:TintTo(MakeRGBA(0, 0, 0, 0), MakeRGBA(1, 1, 1, 0.8), 0.05)
    end)

    self.inst:DoTaskInTime(0.15, function()
        self.flash:TintTo(MakeRGBA(1, 1, 1, 0.8), MakeRGBA(0, 0, 0, 0), 0.05)
    end)

    self.inst:DoTaskInTime(0.2, function()
        self.flash:TintTo(MakeRGBA(0, 0, 0, 0), MakeRGBA(1, 1, 1, 0.8), 0.05)
    end)

    self.inst:DoTaskInTime(0.25, function()
        self.flash:TintTo(MakeRGBA(1, 1, 1, 0.8), MakeRGBA(172 / 255, 39 / 255, 122 / 255, 0.8), 0.1)
    end)

    self.inst:DoTaskInTime(0.35, function()
        self.flash:TintTo(MakeRGBA(172 / 255, 39 / 255, 122 / 255, 0.8), MakeRGBA(132 / 255, 13 / 255, 223 / 255, 0.1),
            0.2)
    end)

    self.inst:DoTaskInTime(0.45, function()
        self.flash:TintTo(MakeRGBA(132 / 255, 13 / 255, 223 / 255, 0.8), MakeRGBA(0, 0, 0, 0), 0.05)
    end)

    -- shards
    for i = 1, 400 do
        local theta = math.random() * PI2
        local radius = GetRandomMinMax(0, 200)
        local radius2 = radius + GetRandomMinMax(0, 1200)
        local dir = Vector3(math.cos(theta), math.sin(theta))

        local start_pos = self.planet:GetPosition() + dir * radius
        local stop_pos = self.planet:GetPosition() + dir * radius2

        local shard = self:MakePlanetShard(start_pos)

        shard:MoveTo(start_pos, stop_pos, GetRandomMinMax(12, 18))
    end
end

function StarIliadOpeningPart1:WeaponSlideIn(duration)
    -- local start_y = 500
    -- local stop_y = -500
    local start_y = 350
    -- local stop_y = -100
    local stop_y = -350


    self.weapon.start_time = GetStaticTime()
    self.weapon.slide_task = self.weapon.inst:DoPeriodicTask(0, function()
        local t = GetStaticTime() - self.weapon.start_time
        -- print("slide_task is:", self.weapon.slide_task)

        if t >= duration then
            self.weapon.slide_task:Cancel()
            -- self.weapon.slide_task = nil
        else
            local cur_y = easing.linear(t, start_y, stop_y - start_y, duration)
            self.weapon:SetPosition(0, cur_y)
        end
    end)

    self.weapon:MoveToFront()


    -- local duration2 = 1
    -- self.weapon.start_time2 = GetStaticTime()
    -- self.weapon.color_task = self.weapon.inst:DoPeriodicTask(0, function()
    --     local t = GetStaticTime() - self.weapon.start_time2

    --     local cur_y = easing.linear(t, start_y, stop_y - start_y, duration)
    -- end)
end

return StarIliadOpeningPart1
