local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local skilltreedefs = require "prefabs/skilltree_defs"
local UIAnim = require "widgets/uianim"

local BlytheSkillActiveFX = Class(UIAnim, function(self)
    UIAnim._ctor(self)

    self:GetAnimState():SetBuild("skills_activate")
    self:GetAnimState():SetBank("skills_activate")
    self:GetAnimState():PlayAnimation("idle")

    self.inst:ListenForEvent("animover", function()
        self:Kill()
    end)
end)

return BlytheSkillActiveFX
