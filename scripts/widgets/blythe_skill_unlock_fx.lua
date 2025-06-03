local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"



local BlytheSkillUnlockFX = Class(Widget, function(self)
    Widget._ctor(self, "BlytheSkillUnlockFX")

    self.anim = self:AddChild(UIAnim())

    self.anim:GetAnimState():SetBuild("skill_unlock")
    self.anim:GetAnimState():SetBank("skill_unlock")
    self.anim:GetAnimState():PlayAnimation("idle")

    self.inst:ListenForEvent("animover", function()
        self:Kill()
    end, self.anim.inst)

    TheFrontEnd:GetSound():PlaySound("wilson_rework/ui/unlock_gatedskill")
end)

return BlytheSkillUnlockFX
