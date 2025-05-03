AddAction("STARILIAD_SHOOT_AT", "STARILIAD_SHOOT_AT", function(act)
    if act.invobject and act.invobject.components.stariliad_pistol then
        act.invobject.components.stariliad_pistol:LaunchProjectile(act.doer, act.target, act:GetActionPoint())
        return true
    end
    return false
end)
ACTIONS.STARILIAD_SHOOT_AT.priority = -1
-- ACTIONS.STARILIAD_SHOOT_AT.distance = 0.1
-- ACTIONS.STARILIAD_SHOOT_AT.arrivedist = 0

local function ExtraShootRange(doer, dest)
    if doer.replica.combat then
        return doer.replica.combat:GetAttackRangeWithWeapon()
    end

    return 0
end
ACTIONS.STARILIAD_SHOOT_AT.extra_arrive_dist = ExtraShootRange

-- ACTIONS.STARILIAD_SHOOT_AT.invalid_hold_action = true

-- AddComponentAction("POINT", "stariliad_pistol", function(inst, doer, pos, actions, right, target)
--     if right
--         and not (doer.replica.rider and doer.replica.rider:IsRiding())
--         and not (doer.replica.inventory and doer.replica.inventory:IsHeavyLifting()) then
--         table.insert(actions, ACTIONS.STARILIAD_SHOOT_AT)
--     end
-- end)


AddComponentAction("EQUIPPED", "stariliad_pistol", function(inst, doer, target, actions, right)
    if not right
        and not (doer.replica.rider and doer.replica.rider:IsRiding())
        and not (doer.replica.inventory and doer.replica.inventory:IsHeavyLifting())
        and inst.replica.stariliad_pistol then
        local data = inst.replica.stariliad_pistol:GetProjectileData()
        if data and data.enable_shoot_at then
            table.insert(actions, ACTIONS.STARILIAD_SHOOT_AT)
        end
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.STARILIAD_SHOOT_AT, function(inst, action)
    -- print("ACTIONS.STARILIAD_SHOOT_AT", GetTime())
    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip ~= nil
        and not (inst.components.rider and inst.components.rider:IsRiding()) then
        if equip.prefab == "blythe_blaster" then
            local proj_data = equip.components.stariliad_pistol:GetProjectileData()
            return proj_data.shoot_at_sg
        end
    end
end))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.STARILIAD_SHOOT_AT, function(inst)
    local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip ~= nil
        and not (inst.replica.rider and inst.replica.rider:IsRiding()) then
        if equip.prefab == "blythe_blaster" then
            local proj_data = equip.replica.stariliad_pistol:GetProjectileData()
            return proj_data.shoot_at_sg
        end
    end
end))
