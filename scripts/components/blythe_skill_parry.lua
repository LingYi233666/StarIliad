local BlytheSkillBase_Active = require "components/blythe_skill_base_active"


local BlytheSkillParry = Class(BlytheSkillBase_Active, function(self, inst)
    BlytheSkillBase_Active._ctor(self, inst)

    -- self.cooldown = 20 * FRAMES
    -- self.costs.hunger = 1

    self.parry_degree = 150
    self.parry_target = inst:SpawnChild("blythe_parry_target")

    self.is_parrying = false
    -- self.counter_timer = nil
    self.can_counter = false

    inst:ListenForEvent("attacked", function(_, data)
        if data.redirected == self.parry_target then
            self:OnAttackedWhileParrying(data)
        end
    end)
end)

function BlytheSkillParry:CanCast(x, y, z, target)
    local can_cost, reason = BlytheSkillBase_Active.CanCast(self, x, y, z, target)
    if not can_cost then
        return can_cost, reason
    end

    if not (self.inst.components.combat and self.inst.components.combat:GetWeapon()) then
        return false, "NO_WEAPON"
    end

    -- if self:IsParrying() then
    --     return false, "ALREADY_PARRYING"
    -- end

    if self:IsInMyCooldown() then
        return false, "IN_MY_COOLDOWN"
    end

    return true
end

-- function BlytheSkillParry:Cast(x, y, z, target)
--     BlytheSkillBase_Active.Cast(self, x, y, z, target)

--     self.inst.sg:GoToState("blythe_parry", { pos = Vector3(x, y, z) })
--     -- self.inst.AnimState:MakeFacingDirty()
--     -- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["make_facing_dirty"], self.inst.userid)
--     -- SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["force_face_point"], self.inst.userid, x, y, z)
--     SendModRPCToClient(CLIENT_MOD_RPC["stariliad_rpc"]["goto_parry_sg"], self.inst.userid, x, y, z)

--     -- local bufferedaction = BufferedAction(self.inst, nil, ACTIONS.BLYTHE_PARRY, nil, Vector3(x, y, z))
--     -- bufferedaction.options.no_predict_fastforward = true
--     -- self.inst:ClearBufferedAction()
--     -- self.inst:PushBufferedAction(bufferedaction)
-- end

function BlytheSkillParry:SetMyCooldown(val, delay)
    self.inst.replica.blythe_skill_parry:SetMyCooldown(val)

    if self.reset_my_cooldown_task then
        self.reset_my_cooldown_task:Cancel()
        self.reset_my_cooldown_task = nil
    end

    if val then
        self.reset_my_cooldown_task = self.inst:DoTaskInTime(delay or (20 * FRAMES), function()
            self:SetMyCooldown(false)
        end)
    end
end

function BlytheSkillParry:IsInMyCooldown()
    return self.inst.replica.blythe_skill_parry:IsInMyCooldown()
end

function BlytheSkillParry:TrySpawnWaterSplash()
    if not self.inst:IsOnOcean() then
        return
    end

    local forward = StarIliadBasic.GetFaceVector(self.inst)
    local fix_pos = self.inst:GetPosition() + forward

    local x, y, z = fix_pos:Get()
    if TheWorld.Map:IsOceanAtPoint(x, y, z) then
        SpawnAt("blythe_parry_water_splash", Vector3(x, y + 1, z))
    end
end

function BlytheSkillParry:IsParrying()
    return self.is_parrying
end

function BlytheSkillParry:OnStartParry()
    self:SetMyCooldown(true, 20 * FRAMES)

    self.is_parrying = true
    self.inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli, spdamage)
        return self:CanParryDamage(attacker, damage, weapon, stimuli, spdamage)
    end
end

function BlytheSkillParry:OnStopParry()
    print("OnStopParry")
    self.is_parrying = false
    self.inst.components.combat.redirectdamagefn = nil
end

function BlytheSkillParry:CanParryDamage(attacker, damage, weapon, stimuli, spdamage)
    if not attacker then
        return
    end

    -- if not self.is_parrying then
    --     return
    -- end

    local tar_deg = StarIliadBasic.GetFaceAngle(self.inst, attacker)

    if math.abs(tar_deg) <= self.parry_degree / 2 then
        return self.parry_target
    end
end

-- function BlytheSkillParry:CanCounter()
--     return self.counter_timer and GetTime() - self.counter_timer < 3
-- end

-- function BlytheSkillParry:ResetCounterTimer()
--     self.counter_timer = nil
-- end

function BlytheSkillParry:SetCanCounter(enable, delay)
    self.can_counter = enable
    if self.can_counter then
        self.inst:AddTag("blythe_can_counter")
    else
        self.inst:RemoveTag("blythe_can_counter")
    end

    if self.delay_cancel_counter_task then
        self.delay_cancel_counter_task:Cancel()
        self.delay_cancel_counter_task = nil
    end

    if enable and delay and delay >= 0 then
        self.delay_cancel_counter_task = self.inst:DoTaskInTime(delay, function()
            self:SetCanCounter(false)
        end)
    end
end

-- function BlytheSkillParry:CanCounter()
--     return self.can_counter
-- end

function BlytheSkillParry:OnAttackedWhileParrying(data)
    -- print("OnAttackedWhileParrying, state name:", self.inst.sg.currentstate.name)

    self.inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/hide_pre", nil, 0.5)
    self.inst:SpawnChild("blythe_parry_spark").Transform:SetPosition(0.5, 0, 0)

    -- self.counter_timer = GetTime()

    -- Add blythe_can_counter, which increases next beam's shot speed and damage
    self:SetCanCounter(true, 3)

    local attacker = data.attacker
    local weapon = data.weapon

    if attacker and attacker:IsValid() then
        local handle_by_projectile = false

        local projectile_prefab = StarIliadParryReflect.GetProjectilePrefab(weapon)
        if projectile_prefab then
            handle_by_projectile = true

            if StarIliadParryReflect.CanReflect(projectile_prefab) then
                StarIliadParryReflect.Reflect(projectile_prefab, self.inst, attacker)
            end
        end


        if not handle_by_projectile
            and self.inst.components.combat:CanTarget(attacker)
            and self.inst:IsNear(attacker, TUNING.DEFAULT_ATTACK_RANGE + 1) then
            local all_damage = TUNING.BLYTHE_PARRY_DAMAGE_MELEE

            local damage = all_damage / 2
            local spdamage = {
                planar = all_damage / 2,
            }
            attacker.components.combat:GetAttacked(self.inst, damage, nil, "electric", spdamage)

            SpawnAt("electrichitsparks", attacker):AlignToTarget(attacker, self.inst, true)
        end

        if StarIliadBasic.IsWorthyEnemy(self.inst, attacker) then
            attacker:AddDebuff("stariliad_debuff_be_parried", "stariliad_debuff_be_parried", { owner = self.inst })
        end
    end
end

return BlytheSkillParry
