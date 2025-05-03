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
                -- StarIliadDebug.PrintStackTrace()

                if inst.sg:HasStateTag("aoe") then
                    return
                else
                    local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                    return proj_data.castaoe_sg
                end
                -- local proj_data = weapon.components.stariliad_pistol:GetProjectileData()
                -- return proj_data.castaoe_sg
            end
        end

        return old_rets
    end
end)

local function SpawnAimReticule(inst, equip, buffaction)
    if equip
        and equip.components.stariliad_pistol
        and buffaction
        and buffaction.target
        and buffaction.target:IsValid() then
        local proj_data = equip.components.stariliad_pistol:GetProjectileData()
        local aim_reticule = proj_data and proj_data.aim_reticule
        if aim_reticule then
            inst.sg.statemem.aim_reticule = SpawnPrefab(aim_reticule)
            inst.sg.statemem.aim_reticule:AttachTarget(buffaction.target)
        end
    end
end

local function KillAimReticule(inst)
    if inst.sg.statemem.aim_reticule and inst.sg.statemem.aim_reticule:IsValid() then
        inst.sg.statemem.aim_reticule:KillFX()
    end
end

local function CreateShootAttackState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

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

            SpawnAimReticule(inst, equip, buffaction)
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

            KillAimReticule(inst)
        end,
    }

    return state
end

local function CreateShootCastAoeState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "notalking", "aoe", "stariliad_no_face_point" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

            inst.components.locomotor:Stop()

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus - chain_bonus)
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus)
            end

            inst.sg.statemem.weapon = equip
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("aoe")
            inst.sg:RemoveStateTag("stariliad_no_face_point")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
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

        end,
    }

    return state
end

local function CreateShootAtState(name, enter_bonus, shoot_time, free_time, chain_bonus)
    local state = State {
        name = name,
        tags = { "notalking", "busy", },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation("hand_shoot")
            inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

            inst.components.locomotor:Stop()

            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(chain_bonus + enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus - chain_bonus)
            else
                inst.AnimState:SetTime(enter_bonus)
                inst.sg:SetTimeout(free_time - enter_bonus)
            end

            inst.sg.statemem.weapon = equip

            SpawnAimReticule(inst, equip, buffaction)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:AddStateTag("idle")
        end,

        timeline =
        {
            TimeEvent(shoot_time - enter_bonus - chain_bonus, function(inst)
                if inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(shoot_time - enter_bonus, function(inst)
                if not inst.sg.statemem.chained then
                    StarIliadBasic.PlayShootSound(inst, inst.sg.statemem.weapon)

                    inst:PerformBufferedAction()
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
            KillAimReticule(inst)
        end,
    }

    return state
end

AddStategraphState("wilson",
    CreateShootAttackState("blythe_shoot_beam",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootCastAoeState("blythe_shoot_beam_castaoe",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootAtState("blythe_shoot_beam_shoot_at",
        TUNING.BLYTHE_BEAM_ENTER_BONUS,
        TUNING.BLYTHE_BEAM_SHOOT_TIME,
        TUNING.BLYTHE_BEAM_FREE_TIME,
        TUNING.BLYTHE_BEAM_CHAIN_BONUS)
)

------------------------------------------------------

AddStategraphState("wilson",
    CreateShootAttackState("blythe_shoot_missile",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)

AddStategraphState("wilson",
    CreateShootCastAoeState("blythe_shoot_missile_castaoe",
        TUNING.BLYTHE_MISSILE_ENTER_BONUS,
        TUNING.BLYTHE_MISSILE_SHOOT_TIME,
        TUNING.BLYTHE_MISSILE_FREE_TIME,
        TUNING.BLYTHE_MISSILE_CHAIN_BONUS)
)
-------------------------------------------------------

AddStategraphState("wilson", State {
    name = "blythe_release_ice_fog",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

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


        if target ~= nil and target:IsValid() then
            inst:FacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.attacktarget = target
            inst.sg.statemem.retarget = target
        end

        -- inst.sg.statemem.chained = inst.AnimState:IsCurrentAnimation("hand_shoot")
        inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

        inst.AnimState:PlayAnimation("hand_shoot")


        local timeout = inst.components.combat.min_attack_period
        if inst.sg.statemem.chained then
            inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
            timeout = math.max(timeout, TUNING.BLYTHE_ICE_FOG_FREE_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
        else
            timeout = math.max(timeout, TUNING.BLYTHE_ICE_FOG_FREE_TIME)
        end

        inst.sg:SetTimeout(timeout)
    end,


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    timeline =
    {
        TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
            if inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
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
)

AddStategraphState("wilson", State {
    name = "blythe_release_ice_fog_castaoe",
    tags = { "notalking", "aoe", "stariliad_no_face_point" },

    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        inst.AnimState:PlayAnimation("hand_shoot")
        inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

        inst.components.locomotor:Stop()

        if inst.sg.statemem.chained then
            inst.AnimState:SetTime(TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
            inst.sg:SetTimeout(TUNING.BLYTHE_ICE_FOG_FREE_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS)
        else
            inst.sg:SetTimeout(TUNING.BLYTHE_ICE_FOG_FREE_TIME)
        end

        inst.sg.statemem.weapon = equip
    end,


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("aoe")
        inst.sg:RemoveStateTag("stariliad_no_face_point")
        inst.sg:AddStateTag("idle")
    end,

    timeline =
    {
        TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
            if inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME - TUNING.BLYTHE_ICE_FOG_CHAIN_BONUS, function(inst)
            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_SHOOT_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(TUNING.BLYTHE_ICE_FOG_WITHDRAW_GUN_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
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

    end,
}
)
