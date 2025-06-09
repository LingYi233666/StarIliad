local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local skilltreedefs = require "prefabs/skilltree_defs"
local UIAnim = require "widgets/uianim"


local BlytheSkillActiveFX = Class(Widget, function(self, sound)
    Widget._ctor(self, "BlytheSkillActiveFX")

    self.anim = self:AddChild(UIAnim())

    self.anim:GetAnimState():SetBuild("skills_activate")
    self.anim:GetAnimState():SetBank("skills_activate")
    self.anim:GetAnimState():PlayAnimation("idle")

    self.anim:SetPosition(0, 15)

    self.inst:ListenForEvent("animover", function()
        self:Kill()
    end, self.anim.inst)

    sound = sound or "wilson_rework/ui/skill_mastered"
    if sound then
        TheFrontEnd:GetSound():PlaySound(sound)
    end
end)

return BlytheSkillActiveFX
