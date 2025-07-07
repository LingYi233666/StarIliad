AddAction("STARILIAD_SHOOT_AT", "STARILIAD_SHOOT_AT", function(act)
    if act.invobject and act.invobject.components.stariliad_pistol then
        act.invobject.components.stariliad_pistol:LaunchProjectile(act.doer, act.target, act:GetActionPoint())
        return true
    end
    return false
end)
ACTIONS.STARILIAD_SHOOT_AT.priority = -1
ACTIONS.STARILIAD_SHOOT_AT.distance = math.huge
-- ACTIONS.STARILIAD_SHOOT_AT.distance = 0.1
-- ACTIONS.STARILIAD_SHOOT_AT.arrivedist = 0

-- local function ExtraShootRange(doer, dest)
--     if doer.replica.combat then
--         return doer.replica.combat:GetAttackRangeWithWeapon()
--     end

--     return 0
-- end
-- ACTIONS.STARILIAD_SHOOT_AT.extra_arrive_dist = ExtraShootRange

-- ACTIONS.STARILIAD_SHOOT_AT.invalid_hold_action = true


AddComponentAction("POINT", "stariliad_pistol", function(inst, doer, pos, actions, right, target)
    if right and not (doer.replica.rider and doer.replica.rider:IsRiding()) then
        table.insert(actions, ACTIONS.STARILIAD_SHOOT_AT)
    end
end)

AddComponentAction("EQUIPPED", "stariliad_pistol", function(inst, doer, target, actions, right)
    if right
        and not (doer.replica.rider and doer.replica.rider:IsRiding())
        and target
        and target ~= doer then
        table.insert(actions, ACTIONS.STARILIAD_SHOOT_AT)
    end
end)

-- AddComponentAction("EQUIPPED", "stariliad_pistol", function(inst, doer, target, actions, right)
--     if not right
--         and not (doer.replica.rider and doer.replica.rider:IsRiding())
--         and not (doer.replica.inventory and doer.replica.inventory:IsHeavyLifting())
--         and inst.replica.stariliad_pistol then
--         local data = inst.replica.stariliad_pistol:GetProjectileData()
--         if data and data.enable_shoot_at then
--             table.insert(actions, ACTIONS.STARILIAD_SHOOT_AT)
--         end
--     end
-- end)

local function GetAttackTag(inst)
    local playercontroller = inst.components.playercontroller
    local attack_tag =
        playercontroller ~= nil and
        playercontroller.remote_authority and
        playercontroller.remote_predicting and
        "abouttoattack" or
        "attack"

    return attack_tag
end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.STARILIAD_SHOOT_AT, function(inst, action)
    -- print("Enter shoot at SG deststate!")

    local attack_tag = GetAttackTag(inst)
    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip ~= nil
        and not (inst.components.rider and inst.components.rider:IsRiding())
        and not (inst.components.health and inst.components.health:IsDead()) then
        if equip.prefab == "blythe_blaster" then
            local proj_data = equip.components.stariliad_pistol:GetProjectileData()
            -- local current_state_name = StarIliadBasic.GetCurrentStateName(inst)
            if not inst.sg:HasStateTag(attack_tag) then
                -- print("Go to attack sg")
                return proj_data.attack_sg
                -- elseif current_state_name == proj_data.attack_sg then
                --     -- Update position
                --     if inst.sg.statemem.action then
                --         local pos = action:GetActionPoint()
                --         if pos then
                --             inst.sg.statemem.action:SetActionPoint(pos)
                --         else
                --             inst.sg.statemem.action.pos = nil
                --         end
                --         inst.sg.statemem.action.target = action.target
                --     end
            end
        end
    end
end))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.STARILIAD_SHOOT_AT, function(inst, action)
    local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip ~= nil
        and not (inst.replica.rider and inst.replica.rider:IsRiding())
        and not IsEntityDead(inst, true) then
        if equip.prefab == "blythe_blaster" then
            local proj_data = equip.replica.stariliad_pistol:GetProjectileData()
            -- local current_state_name = StarIliadBasic.GetCurrentStateName(inst)

            if not inst.sg:HasStateTag("attack") then
                return proj_data.attack_sg
                -- elseif current_state_name == proj_data.attack_sg then
                --     -- Update position to server
                --     local x, y, z
                --     local action_pos = action:GetActionPoint()
                --     if action_pos then
                --         x, y, z = action_pos:Get()
                --     end
                --     SendModRPCToServer(MOD_RPC["stariliad_rpc"]["set_shoot_action_data"], x, y, z, action.target)
            end
        end
    end
end))

--------------------------------------------------------------

AddAction("STARILIAD_OCEAN_LAND_JUMP", "STARILIAD_OCEAN_LAND_JUMP", function(act)
    return true
end)
ACTIONS.STARILIAD_OCEAN_LAND_JUMP.priority = 0
ACTIONS.STARILIAD_OCEAN_LAND_JUMP.distance = 3
ACTIONS.STARILIAD_OCEAN_LAND_JUMP.strfn = function(act)
    local dest_pos = act:GetActionPoint()
    if TheWorld.Map:IsOceanAtPoint(dest_pos:Get()) then
        return "TO_OCEAN"
    end

    return "TO_LAND"
end
ACTIONS.STARILIAD_OCEAN_LAND_JUMP.pre_action_cb = function(act)
    local my_pos = act.doer:GetPosition()
    local dest_pos = act:GetActionPoint()
    local delta_pos = dest_pos - my_pos
    local forward = delta_pos:GetNormalized()
    local step = 0.2
    local search_distance = math.min(delta_pos:Length(), 10)
    local num_steps = search_distance / step

    local search_bool = not act.doer:IsOnOcean()

    num_steps = math.ceil(num_steps)
    step = delta_pos:Length() / num_steps

    local step2 = 1
    -- local search_distance2 = 1

    for i = 0, num_steps do
        local tmp_pos = my_pos + forward * i * step
        if TheWorld.Map:IsOceanAtPoint(tmp_pos:Get()) == search_bool then
            local tmp_pos2 = tmp_pos + forward * step2
            if TheWorld.Map:IsOceanAtPoint(tmp_pos2:Get()) == search_bool then
                act:SetActionPoint((tmp_pos + tmp_pos2) / 2)
                break
            end
        end
    end
end


AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.STARILIAD_OCEAN_LAND_JUMP, function(inst, action)
    return "stariliad_ocean_land_jump"
end))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.STARILIAD_OCEAN_LAND_JUMP, function(inst)
    inst:PerformPreviewBufferedAction()
end))

--------------------------------------------------------------

-- AddAction("BLYTHE_PARRY", "BLYTHE_PARRY", function(act)
--     act.doer:PushEvent("blythe_parry_target_pos", { pos = act:GetActionPoint() })
--     return true
-- end)

-- AddAction("BLYTHE_PARRY", "BLYTHE_PARRY", function(act)
--     return true
-- end)

-- ACTIONS.BLYTHE_PARRY.distance = math.huge

-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.BLYTHE_PARRY, "blythe_parry"))

-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.BLYTHE_PARRY, "blythe_parry"))

--------------------------------------------------------------

AddAction("BLYTHE_UNLOCK_SKILL", "BLYTHE_UNLOCK_SKILL", function(act)
    local teacher = nil
    if act.invobject and act.invobject:IsValid() and act.invobject.components.blythe_unlock_skill then
        teacher = act.invobject
    elseif act.target and act.target:IsValid() and act.target.components.blythe_unlock_skill then
        teacher = act.target
    end

    if not teacher then
        return false
    end

    local success, reason = teacher.components.blythe_unlock_skill:Teach(act.doer)

    return success, reason
end)

AddComponentAction("INVENTORY", "blythe_unlock_skill", function(inst, doer, actions, right)
    if inst:IsValid() and inst.replica.inventoryitem and doer:IsValid() and doer.replica.blythe_skiller then
        table.insert(actions, ACTIONS.BLYTHE_UNLOCK_SKILL)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.BLYTHE_UNLOCK_SKILL, "dolongaction"))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.BLYTHE_UNLOCK_SKILL, "dolongaction"))
