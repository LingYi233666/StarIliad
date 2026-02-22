local TEMPLATES = require "widgets/redux/templates"
local easing = require("easing")

local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"


local StarIliadOpeningPart2 = Class(Widget, function(self)
    Widget._ctor(self, "StarIliadOpeningPart2")

    self.bg = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.bg:SetTint(0, 0, 0, 1)

    self.energy = self:AddChild(UIAnim())
    self.energy:GetAnimState():SetBank("archive_security_pulse")
    self.energy:GetAnimState():SetBuild("archive_security_pulse")
    self.energy:GetAnimState():PlayAnimation("idle", true)
    self.energy:SetScale(0.5)
    self.energy:SetPosition(0, -135)

    self.energy_container = self:AddChild(UIAnim())
    self.energy_container:GetAnimState():SetBank("stariliad_cutscene_opening")
    self.energy_container:GetAnimState():SetBuild("stariliad_cutscene_opening")
    self.energy_container:GetAnimState():PlayAnimation("container", true)
    self.energy_container:GetAnimState():UsePointFiltering(true)
    -- self.energy_container:GetAnimState():SetMultColour(0, 0.7, 1, 1)
    self.energy_container:SetPosition(0, 0)
    self.energy_container:SetScale(2.6)

    -- projectile data
    -- bank: shadow_thrall_projectile_fx
    -- build: shadow_thrall_projectile_fx
    -- anims: idle_loop projectile_impact

    self.text = self:AddChild(Text(TALKINGFONT, 68))
    self.text:SetHAnchor(ANCHOR_MIDDLE)
    self.text:SetVAnchor(ANCHOR_BOTTOM)
    self.text:SetMultilineTruncatedString(STRINGS.STARILIAD_UI.CUTSCENES.INTRO[2], 99999, 900)
    self.text:SetPosition(0, 100)
end)


function StarIliadOpeningPart2:MakeSmallExplode(pos, rot)
    local explode = self:AddChild(UIAnim())
    explode:GetAnimState():SetBank("shadow_thrall_projectile_fx")
    explode:GetAnimState():SetBuild("shadow_thrall_projectile_fx")
    explode:GetAnimState():PlayAnimation("projectile_impact")
    explode:GetAnimState():UsePointFiltering(true)
    explode:SetPosition(pos)
    explode:SetRotation(rot)
    explode:SetScale(0.5)

    explode.inst:ListenForEvent("animover", function()
        explode:Kill()
    end)

    return explode
end

function StarIliadOpeningPart2:LaunchProjectile(start_pos, end_pos, speed)
    local proj = self:AddChild(UIAnim())
    proj:GetAnimState():SetBank("shadow_thrall_projectile_fx")
    proj:GetAnimState():SetBuild("shadow_thrall_projectile_fx")
    proj:GetAnimState():PlayAnimation("idle_loop", true)
    proj:GetAnimState():UsePointFiltering(true)
    proj:SetPosition(start_pos)
    proj:SetScale(0.5)

    local delta_pos = end_pos - start_pos
    local duration = delta_pos:Length() / speed

    local deg = -math.atan2(delta_pos.y, delta_pos.x) * RADIANS - 90
    proj:SetRotation(deg)

    proj.start_time = GetStaticTime()
    proj.task = proj.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - proj.start_time
        local cur_pos = easing.linear(cur_t, start_pos, delta_pos, duration)

        proj:SetPosition(cur_pos)

        if cur_t >= duration then
            self:MakeSmallExplode(proj:GetPosition(), deg)

            proj.task:Cancel()
            proj:Kill()
        end
    end)

    return proj
end

function StarIliadOpeningPart2:StartLaunchProjectiles()
    self.launch_proj_task = self.inst:DoPeriodicTask(0.1, function()
        local speed = 1000
        self:LaunchProjectile(Vector3(700, 200), Vector3(50, 20), speed)
        self:LaunchProjectile(Vector3(-700, 200), Vector3(-50, 20), speed)
    end)
end

function StarIliadOpeningPart2:StopLaunchProjectiles()
    if self.launch_proj_task then
        self.launch_proj_task:Cancel()
    end
    self.launch_proj_task = nil
end

function StarIliadOpeningPart2:EnergyFadeOut(duration)
    self.energy.start_time = GetStaticTime()

    self.energy.task = self.energy.inst:DoPeriodicTask(0, function()
        local cur_t = GetStaticTime() - self.energy.start_time
        local cur_a = easing.linear(cur_t, 1, -1, duration)

        self.energy:GetAnimState():SetMultColour(1, 1, 1, cur_a)

        if cur_t >= duration then
            self.energy.task:Cancel()
            self.energy:Kill()
        end
    end)
end

function StarIliadOpeningPart2:StartContainerShaking()
    local function ShakeTask()
        local dest = self.energy_container.flag and Vector3(0, 5) or Vector3(0, -5)

        self.energy_container.flag = not self.energy_container.flag
        self.energy_container:MoveTo(self.energy_container:GetPosition(), dest, 0.05, function()
            ShakeTask()
        end)
    end

    ShakeTask()
end

function StarIliadOpeningPart2:StopContainerShaking()
    self.energy_container:CancelMoveTo()
end

function StarIliadOpeningPart2:SpawnGlassShards(center)
    local acc_y = -600

    for i = 1, 60 do
        local offset = Vector3(math.random(-150, 150), math.random(-50, 50))
        local pos = center + offset

        local init_speed = Vector3(math.random(0, 400), math.random(-50, 200))
        if offset.x < 0 then
            init_speed.x = -init_speed.x
        end

        local shard = self:AddChild(UIAnim())
        shard:GetAnimState():SetBank("stariliad_cutscene_opening")
        shard:GetAnimState():SetBuild("stariliad_cutscene_opening")
        shard:GetAnimState():PlayAnimation("glass_shard", true)
        shard:GetAnimState():UsePointFiltering(true)
        shard:SetRotation(math.random() * 360)
        shard:SetPosition(pos)
        shard:SetScale(1.5)

        shard.start_time = GetStaticTime()
        shard.task = shard.inst:DoPeriodicTask(0, function()
            local cur_t = GetStaticTime() - shard.start_time
            local dest = pos + init_speed * cur_t + Vector3(0, acc_y) * 0.5 * cur_t * cur_t
            shard:SetPosition(dest)
        end)
        shard.task2 = shard.inst:DoPeriodicTask(0, function()
            if shard.flag then
                shard:GetAnimState():SetMultColour(1, 1, 1, 1)
            else
                shard:GetAnimState():SetMultColour(0, 0, 0, 0)
            end

            shard.flag = not shard.flag
        end)
    end
end

function StarIliadOpeningPart2:Play()
    self.inst:DoTaskInTime(1.8, function()
        self:StartLaunchProjectiles()

        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/glass_shaking")
    end)

    self.inst:DoTaskInTime(2.8, function()
        self:StopLaunchProjectiles()
    end)

    self.inst:DoTaskInTime(3.5, function()
        self:EnergyFadeOut(0.3)
    end)

    self.inst:DoTaskInTime(3.8, function()
        self.energy_container:GetAnimState():PlayAnimation("container_crack")
    end)

    local crack_t = { 3.8, 4, 4.25, 4.5 }
    for _, t in pairs(crack_t) do
        self.inst:DoTaskInTime(t, function()
            TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/glass_crack")
        end)
    end

    self.inst:DoTaskInTime(4.6, function()
        self:StartContainerShaking()
        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/glass_shaking")
    end)

    self.inst:DoTaskInTime(6.1, function()
        self:StopContainerShaking()

        self:SpawnGlassShards(self.energy_container:GetPosition())

        self.energy_container:GetAnimState():SetDeltaTimeMultiplier(2)
        self.energy_container:GetAnimState():PlayAnimation("container_break2")

        TheFrontEnd:GetSound():PlaySound("stariliad_sfx/hud/opening/glass_break")
    end)

    self.inst:DoTaskInTime(6.8, function()
        self.energy_container.task = self.energy_container.inst:DoPeriodicTask(0, function()
            if self.energy_container.flag then
                self.energy_container:GetAnimState():SetMultColour(1, 1, 1, 0.5)
            else
                self.energy_container:GetAnimState():SetMultColour(1, 1, 1, 0)
            end

            self.energy_container.flag = not self.energy_container.flag
        end)
    end)
end

return StarIliadOpeningPart2
