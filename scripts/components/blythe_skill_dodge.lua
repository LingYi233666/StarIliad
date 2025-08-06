local BlytheSkillBase_Active = require "components/blythe_skill_base_active"


local BlytheSkillDodge = Class(BlytheSkillBase_Active, function(self, inst)
    BlytheSkillBase_Active._ctor(self, inst)

    self.cooldown = FRAMES
    self.costs.hunger = 1

    self.can_cast_while_busy = true

    self.dodge_speed = 40
    self.max_dodge_charge = 2
    self.dodge_charge = self.max_dodge_charge
    -- self.resume_delay = 0.1
    self.resume_delay = 3
end)

function BlytheSkillDodge:CanCast(x, y, z, target)
    local can_cost, reason = BlytheSkillBase_Active.CanCast(self, x, y, z, target)
    if not can_cost then
        return can_cost, reason
    end

    -- if self.inst:IsOnOcean() then
    --     return false, "ON_OCEAN"
    -- end

    local run_speed = self.inst.components.locomotor:GetRunSpeed()
    if run_speed < 5.5 then
        return false, "TOO_SLOW"
    end

    if self.dodge_charge <= 0 then
        return false, "NO_DODGE_CHARGE"
    end

    return true
end

function BlytheSkillDodge:Cast(x, y, z, target)
    BlytheSkillBase_Active.Cast(self, x, y, z, target)

    self.inst.sg:GoToState("blythe_dodge", { pos = Vector3(x, y, z) })
end

function BlytheSkillDodge:OnDodgeStart(target_pos)
    if self.inst.components.inventory:IsHeavyLifting() then
        self.inst.components.inventory:DropItem(
            self.inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end

    self.inst.components.locomotor:Stop()

    self.inst:ForceFacePoint(target_pos)
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)

    self.inst.components.health:SetInvincible(true)

    -- self.inst.AnimState:SetMultColour(1, 1, 1, 0.3)
    self.inst.AnimState:SetAddColour(50 / 255, 229 / 255, 232 / 255, 1)
    -- self.inst.AnimState:SetMultColour(10 / 255, 240 / 255, 200 / 255, 0.3)
    self.inst.AnimState:SetHaunted(true)

    SpawnAt("blythe_dodge_start_circle", self.inst)

    local fx1 = self.inst:SpawnChild("blythe_dodge_tail_blue")
    fx1:DoTaskInTime(0.15, fx1.Remove)

    local fx2 = self.inst:SpawnChild("blythe_dodge_flame")
    fx2.entity:AddFollower()
    fx2.Follower:FollowSymbol(self.inst.GUID, "torso", 0, -50, 0)

    self.dodge_fx = {
        -- fx1,
        fx2
    }

    self:SpawnClone()

    self.dodge_charge = self.dodge_charge - 1
    if self.dodge_charge_resume_task then
        self.dodge_charge_resume_task:Cancel()
    end
    self.dodge_charge_resume_task = self.inst:DoTaskInTime(self.resume_delay, function()
        self.dodge_charge = self.max_dodge_charge
        self.dodge_charge_resume_task = nil
    end)

    -- self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/dodge")
    self.inst.SoundEmitter:PlaySound("stariliad_sfx/character/skill/dodge_icey")
end

function BlytheSkillDodge:OnDodging()
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)
end

function BlytheSkillDodge:SpawnClone()
    local clone = SpawnAt("blythe_clone", self.inst)
    if clone then
        local equip = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        clone:Copy(self.inst)
        clone.Transform:SetRotation(self.inst.Transform:GetRotation())

        -- if equip then
        --     clone.AnimState:PlayAnimation("atk_leap_lag")
        -- else
        --     -- clone.AnimState:PlayAnimation("blythe_speedrun_pre")
        --     -- clone.AnimState:PushAnimation("blythe_speedrun_loop", false)

        --     clone.AnimState:SetPercent("blythe_speedrun_loop", 0.1)
        -- end
        clone.AnimState:SetPercent("blythe_speedrun_loop", 0.1)

        clone.AnimState:SetAddColour(100 / 255, 240 / 255, 230 / 255, 1)
        clone.AnimState:SetMultColour(1, 1, 1, 0)
        clone.AnimState:SetLightOverride(1)

        clone.acc = -12
        clone.speed = 6
        clone.Physics:SetMotorVel(clone.speed, 0, 0)
        clone.speed_task = clone:DoPeriodicTask(0, function()
            clone.speed = math.max(0, clone.speed + clone.acc * FRAMES)
            clone.Physics:SetMotorVel(clone.speed, 0, 0)

            if clone.speed <= 0 then
                clone.speed_task:Cancel()
                clone.speed_task = nil
            end
        end)

        clone:FadeIn(0.1)

        clone:DoTaskInTime(0.1 + FRAMES, function()
            clone:FadeOut(0.4)
        end)
    end
end

function BlytheSkillDodge:ClearDodgeFX()
    if self.dodge_fx then
        for _, v in pairs(self.dodge_fx) do
            if v:IsValid() then
                -- if v._static_event then
                --     v._static_event:push()
                --     v:DoTaskInTime(FRAMES, v.Remove)
                -- else
                --     v:Remove()
                -- end
                v:Remove()
            end
        end
        self.dodge_fx = nil
    end
end

function BlytheSkillDodge:OnDodgeStop()
    self.inst.Physics:ClearMotorVelOverride()
    self.inst.Physics:Stop()

    self.inst.AnimState:SetMultColour(1, 1, 1, 1)
    self.inst.AnimState:SetAddColour(0, 0, 0, 0)
    self.inst.AnimState:SetHaunted(false)


    self:ClearDodgeFX()

    self.inst.components.health:SetInvincible(false)
end

return BlytheSkillDodge
