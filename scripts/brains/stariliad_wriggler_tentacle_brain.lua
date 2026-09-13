require "behaviours/chaseandattack"
require "behaviours/wander"

local StariliadWrigglerTentacleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldDash(inst)
    if inst.components.health:IsDead() then
        return
    end

    local target = inst.components.combat.target
    if not target then
        return
    end

    if not target:IsNear(inst, 25) then
        return
    end

    return inst.components.combat:InCooldown() and
        (GetTime() - (inst.last_dash_time or 0)) > 10
end

local function GetHomePos(inst)
    return inst.components.knownlocations and inst.components.knownlocations:GetLocation("home")
end

local function ShouldGoHome(inst)
    local home_pos = GetHomePos(inst)

    return home_pos and (home_pos - inst:GetPosition()):Length() > 40
end

local function CastDash(inst)
    inst.last_dash_time = GetTime()

    local target = inst.components.combat.target
    inst.sg:GoToState("attack_dash", {
        face_pos = target and target:GetPosition(),
        max_dist = 12,
        stop_time = GetTime() + 4,
    })
end

local function GoHomeAction(inst)
    if inst.components.combat:HasTarget() then
        return
    end

    local home_pos = inst.components.knownlocations:GetLocation("home")
    return home_pos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, home_pos, nil, 6)
        or nil
end


function StariliadWrigglerTentacleBrain:OnStart()
    local root = PriorityNode(
        {
            -- Too strong
            -- FailIfSuccessDecorator(IfNode(
            --     function()
            --         return ShouldDash(self.inst)
            --     end,
            --     "ShouldDash",
            --     ActionNode(function() CastDash(self.inst) end)
            -- )),

            WhileNode(
                function()
                    return self.inst.components.combat.target ~= nil
                        and self.inst.components.combat:InCooldown()
                end,
                "AvoidTarget",
                RunAway(self.inst, {
                    getfn = function()
                        return self.inst.components.combat.target
                    end
                }, 5, 14)
            ),

            ChaseAndAttack(self.inst,
                20, -- max chase time
                50  -- max chase distance
            ),

            -- Go back to spawn point
            WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
                DoAction(self.inst, GoHomeAction, "Go Home", true)),


            Wander(self.inst,
                GetHomePos, -- home location
                32          -- max wander distance
            ),
        }, .25)

    self.bt = BT(self.inst, root)
end

return StariliadWrigglerTentacleBrain
