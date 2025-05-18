local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local StarIliadSkillSlot = Class(ImageButton, function(self, skill_name)
    local atlas = "images/global.xml"
    local image = "square.tex"

    ImageButton._ctor(self, atlas, image, image, image, image, image)

    local default_scale = 1.1

    self.icon = self:AddChild(Image())
    self.icon:Hide()
    self.icon:SetScale(default_scale)

    self:SetNormalScale(default_scale)
    self:SetFocusScale(default_scale)

    if skill_name then
        self:SetSkillName(skill_name)
    end
    self:EnableIcon(true)
end)

function StarIliadSkillSlot:SetSkillName(skill_name)
    assert(skill_name ~= nil)
    assert(StarIliadBasic.GetSkillDefine(skill_name) ~= nil)

    self.skill_name = skill_name

    local imagename = skill_name:lower()

    local atlas = "images/ui/skill_slot/" .. imagename .. ".xml"
    local image = imagename .. ".tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        atlas = "images/ui/skill_slot/unknown.xml"
        image = "unknown.tex"
        search_result = softresolvefilepath(atlas)
    end

    if search_result == nil then
        -- print("StarIliadSkillSlot Can't find " .. atlas .. ",use default...")
        self.icon:Hide()
    else
        self.icon:SetTexture(atlas, image)
        self.icon:SetSize(55, 55)
        self.icon:Show()
    end
end

function StarIliadSkillSlot:EnableIcon(enable)
    if enable then
        self.icon:SetTint(1, 1, 1, 1)
    else
        self.icon:SetTint(0, 0, 0, 1)
    end
    self.image:SetTint(0.5, 0.5, 0.5, 0.25)
end

return StarIliadSkillSlot
