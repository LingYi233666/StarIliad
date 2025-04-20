-- AddAction("STARILIAD_FREE_SHOOT", "STARILIAD_FREE_SHOOT", function(act)
--     if act.invobject and act.invobject.components.stariliad_pistol then
--         act.invobject.components.stariliad_pistol:LaunchProjectile(act.doer, act.target, act:GetActionPoint())
--         return true
--     end
--     return false
-- end)
-- ACTIONS.STARILIAD_FREE_SHOOT.distance = TUNING.BLYTHE_BLASTER_ATTACK_RANGE
-- -- ACTIONS.STARILIAD_FREE_SHOOT.invalid_hold_action = true

-- AddComponentAction("POINT", "stariliad_pistol", function(inst, doer, pos, actions, right, target)
--     if right
--         and not (doer.replica.rider and doer.replica.rider:IsRiding())
--         and not (doer.replica.inventory and doer.replica.inventory:IsHeavyLifting()) then
--         table.insert(actions, ACTIONS.STARILIAD_FREE_SHOOT)
--     end
-- end)


-- AddComponentAction("EQUIPPED", "stariliad_pistol", function(inst, doer, target, actions, right)
--     if right
--         and not (doer.replica.rider and doer.replica.rider:IsRiding())
--         and not (doer.replica.inventory and doer.replica.inventory:IsHeavyLifting()) then
--         table.insert(actions, ACTIONS.STARILIAD_FREE_SHOOT)
--     end
-- end)

-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.STARILIAD_FREE_SHOOT, function(inst, action)
--     -- print("ACTIONS.STARILIAD_FREE_SHOOT", GetTime())


--     local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--     if equip ~= nil
--         and not (inst.components.rider and inst.components.rider:IsRiding()) then
--         if equip.prefab == "blythe_blaster" then
--             if inst.sg.statemem.stariliad_free_shoot_flag then

--             else
--                 -- StarIliadDebug.PrintStackTrace()

--                 local proj_data = equip.components.stariliad_pistol:GetProjectileData()
--                 return proj_data.attack_sg
--             end
--         end
--     end
-- end))

-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.STARILIAD_FREE_SHOOT, function(inst)
--     local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--     if equip ~= nil
--         and not (inst.replica.rider and inst.replica.rider:IsRiding())
--         and not inst.sg.statemem.stariliad_free_shoot_flag then
--         if equip.prefab == "blythe_blaster" then
--             local proj_data = equip.replica.stariliad_pistol:GetProjectileData()
--             return proj_data.attack_sg
--         end
--     end
-- end))
