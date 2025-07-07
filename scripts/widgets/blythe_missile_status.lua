local Widget              = require "widgets/widget"
local Image               = require "widgets/image"
local Text                = require "widgets/text"
local Grid                = require "widgets/grid"
local TEMPLATES           = require "widgets/redux/templates"

local BlytheSkillActiveFX = require "widgets/blythe_skill_active_fx"

-- STRINGS.STARILIAD_UI.BLYTHE_MISSILE_STATUS

local BlytheMissileStatus = Class(Widget, function(self, owner)
    Widget._ctor(self, "BlytheMissileStatus")

    self.owner = owner

    self.missile = self:AddChild(Image("images/ui/missile_status/missile.xml", "missile.tex"))
    self.missile:SetScale(0.4, 0.4)
    self.missile:SetPosition(-122, 0)
    self.missile:SetTooltip(STRINGS.STARILIAD_UI.BLYTHE_MISSILE_STATUS.MISSILE)
    self.missile:Hide()

    self.label_1 = self:AddChild(Text(NUMBERFONT, 29))
    self.label_1:SetPosition(-120, -40)
    self.label_1:Hide()

    -- self.block_1 = self:AddChild(Image("images/global.xml", "square.tex"))
    -- self.block_1:SetSize(64, 64)
    -- self.block_1:Hide()

    self.super_missile = self:AddChild(Image("images/ui/missile_status/super_missile.xml", "super_missile.tex"))
    self.super_missile:SetScale(0.47, 0.47)
    self.super_missile:SetPosition(-60, 3)
    self.super_missile:SetTooltip(STRINGS.STARILIAD_UI.BLYTHE_MISSILE_STATUS.SUPER_MISSILE)
    self.super_missile:Hide()

    self.label_2 = self:AddChild(Text(NUMBERFONT, 29))
    self.label_2:SetPosition(-58, -40)
    self.label_2:Hide()

    self.inst:DoTaskInTime(1, function()
        self:ForceUpdate(true)
        self:StartUpdating()
    end)
end)

function BlytheMissileStatus:SpawnFX(is_super)
    if self.flash_task then
        self.flash_task:Cancel()
        self.flash_task = nil
    end

    if self.flash_task2 then
        self.flash_task2:Cancel()
        self.flash_task2 = nil
    end

    local color_1 = { 0, 1, 0, 1 }

    self.label_1:SetColour({ 1, 1, 1, 1 })
    self.label_2:SetColour({ 1, 1, 1, 1 })

    local fx = self:AddChild(BlytheSkillActiveFX("stariliad_sfx/hud/item_acquired_normal2"))
    if is_super then
        fx:SetPosition(self.super_missile:GetPosition())
    else
        fx:SetPosition(self.missile:GetPosition())
    end

    local flag = true
    self.flash_task = self.inst:DoStaticPeriodicTask(FRAMES, function()
        if is_super then
            self.label_2:SetColour(flag and color_1 or { 1, 1, 1, 1 })
        else
            self.label_1:SetColour(flag and color_1 or { 1, 1, 1, 1 })
        end
        flag = not flag
    end)

    self.flash_task2 = self.inst:DoStaticTaskInTime(1, function()
        if self.flash_task then
            self.flash_task:Cancel()
            self.flash_task = nil
        end

        self.label_1:SetColour({ 1, 1, 1, 1 })
        self.label_2:SetColour({ 1, 1, 1, 1 })

        self.flash_task2 = nil
    end)
end

function BlytheMissileStatus:ForceUpdate(is_init)
    local counter = self.owner.replica.blythe_missile_counter
    local skiller = self.owner.replica.blythe_skiller

    local num_missiles = counter:GetNumMissiles()
    local max_num_missiles = counter:GetMaxNumMissiles()
    local num_super_missiles = counter:GetNumSuperMissiles()
    local max_num_super_missiles = counter:GetMaxNumSuperMissiles()

    local learned_missile = skiller:IsLearned("missile")
    local learned_super_missile = skiller:IsLearned("super_missile")


    if learned_missile and not self.missile.shown then
        self.missile:Show()
        self.label_1:Show()
    elseif not learned_missile and self.missile.shown then
        self.missile:Hide()
        self.label_1:Hide()
    end

    if learned_super_missile and not self.super_missile.shown then
        self.super_missile:Show()
        self.label_2:Show()
    elseif not learned_super_missile and self.super_missile.shown then
        self.super_missile:Hide()
        self.label_2:Hide()
    end

    self.label_1:SetString(string.format("%d/%d", num_missiles, max_num_missiles))
    self.label_2:SetString(string.format("%d/%d", num_super_missiles, max_num_super_missiles))
end

function BlytheMissileStatus:OnUpdate()
    self:ForceUpdate()
end

return BlytheMissileStatus
