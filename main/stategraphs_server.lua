-- attack
AddStategraphPostInit("wilson", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local old_rets = old_ATTACK(inst, action)
        local weapon = inst.components.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                return proj_data.attack_sg
            end
        end

        return old_rets
    end
end)

-- castaoe
AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local old_rets = old_CASTAOE(inst, action)
        local weapon = inst.components.combat:GetWeapon()
        if old_rets ~= nil
            and weapon ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if weapon.prefab == "blythe_blaster" then
                -- if inst.sg:HasStateTag("attack") then
                --     return
                -- else
                --     local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                --     return proj_data.castaoe_sg
                -- end
                local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                return proj_data.castaoe_sg
            end
        end

        return old_rets
    end
end)


local function CreateShootState(name, enter_bonus, shoot_time, free_time, chain_bonus, extra_tags)
    extra_tags = extra_tags or {}

    local state = State {
        name = name,
        tags = ArrayUnion({ "attack", "notalking", "abouttoattack", "autopredict" }, extra_tags),

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(math.max(
                    free_time - enter_bonus - chain_bonus,
                    inst.components.combat.min_attack_period))
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(math.max(free_time - enter_bonus,
                    inst.components.combat.min_attack_period))
            end

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end

            inst.sg.statemem.weapon = equip
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:RemoveStateTag("busy")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    }

    return state
end


AddStategraphState("wilson",
    CreateShootState("blythe_shoot_beam",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootState("blythe_shoot_beam_castaoe",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootState("blythe_shoot_missile",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootState("blythe_shoot_missile_castaoe",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)
