local BlytheSkillParry = Class(function(self, inst)
    self.inst = inst

    self._m_in_cooldown = net_bool(inst.GUID, "BlytheSkillParry._m_in_cooldown")
    self._m_in_cooldown:set(false)
end)

function BlytheSkillParry:SetMyCooldown(val)
    self._m_in_cooldown:set(val)
end

function BlytheSkillParry:IsInMyCooldown()
    return self._m_in_cooldown:value()
end

function BlytheSkillParry:CanCast()
    return not self.inst:HasTag("busy")
        and not self.inst:HasTag("nointerrupt")
        and not IsEntityDeadOrGhost(self.inst)
        and not (self.inst.replica.rider and self.inst.replica.rider:IsRiding())
        and (self.inst.replica.combat and self.inst.replica.combat:GetWeapon())
        and not self:IsInMyCooldown()
end

function BlytheSkillParry:Cast(x, y, z)
    -- local playercontroller = self.inst.components.playercontroller
    -- if not playercontroller then
    --     return
    -- end

    -- local act = BufferedAction(self.inst, nil, ACTIONS.BLYTHE_PARRY, nil, Vector3(x, y, z))

    -- if playercontroller.ismastersim then
    --     self.inst.components.combat:SetTarget(nil)
    --     playercontroller:DoAction(act)
    --     return
    -- end

    if self.inst.sg and self.inst.sg:HasState("blythe_parry") then
        self.inst.sg:GoToState("blythe_parry", { pos = Vector3(x, y, z) })
    end

    SendModRPCToServer(MOD_RPC["stariliad_rpc"]["goto_parry_sg"], x, y, z)
end

return BlytheSkillParry
