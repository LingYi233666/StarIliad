require "behaviours/chaseandattack"
require "behaviours/wander"

local function ShouldSkillPound(inst)
    if inst.components.health:IsDead() or inst.sg:HasStateTag("busy") then
        return
    end

    local target = inst.components.combat.target

    if not target or not target:IsValid() then
        return
    end

    local distsq = inst:GetDistanceSqToInst(target)

    return distsq > TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_RANGE * TUNING.STARILIAD_BOSS_TOAD_PARASITE_ATTACK_RANGE
        and distsq < 14 * 14
        and not inst.components.combat:InCooldown()
    -- and inst.sg.mem.last_attack ~= "pound"
end

local function UseSkillPound(inst)
    inst.sg:GoToState("attack_pound_pre", { num_to_pound = 4 })
    inst.sg.mem.last_attack = "pound"
end

local StariliadBossToadParasiteBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StariliadBossToadParasiteBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(function() return ShouldSkillPound(self.inst) end, "SkillPound",
                ActionNode(function()
                    UseSkillPound(self.inst)
                end)),

            ChaseAndAttack(self.inst,
                20, -- max chase time
                50  -- max chase distance
            ),

            Wander(self.inst,
                nil, -- home location
                32   -- max wander distance
            ),
        }, .25)

    self.bt = BT(self.inst, root)
end

return StariliadBossToadParasiteBrain
